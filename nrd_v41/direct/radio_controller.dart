import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class NrdRadioController extends ChangeNotifier {
  NrdRadioController._();
  static final NrdRadioController instance = NrdRadioController._();
  static const streamUrl = 'https://s3.radio.co/s97f38db97/listen';

  final AudioPlayer player = AudioPlayer();
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<PlayerException>? _errorSub;
  Timer? _reconnectTimer;
  bool _initialised = false;
  bool _userWantsPlayback = false;
  int _reconnectAttempt = 0;
  String status = 'Ready to play';

  bool get playing => player.playing;
  double get volume => player.volume;

  Future<void> initialise() async {
    if (_initialised) return;
    _initialised = true;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await player.setAudioSource(
      AudioSource.uri(
        Uri.parse(streamUrl),
        tag: MediaItem(
          id: 'nrd-live-radio',
          album: 'National Revival Desk',
          title: 'Jesus is LORD Radio',
          artist: 'Live Ministry Broadcast',
          artUri: Uri.parse('https://www.nationalrevivaldesk.com/assets/img/icon-512.png'),
          isLive: true,
        ),
      ),
      preload: false,
    );
    _stateSub = player.playerStateStream.listen((state) {
      if (state.playing) {
        status = state.processingState == ProcessingState.buffering || state.processingState == ProcessingState.loading
            ? 'Buffering live stream…'
            : 'Live now';
        if (state.processingState == ProcessingState.ready) _reconnectAttempt = 0;
      } else {
        status = _userWantsPlayback ? 'Playback interrupted — reconnecting' : 'Paused';
      }
      if (state.processingState == ProcessingState.idle && _userWantsPlayback) _scheduleReconnect();
      notifyListeners();
    });
    _errorSub = player.errorStream.listen((error) {
      status = 'Stream interrupted — reconnecting';
      notifyListeners();
      _scheduleReconnect();
    });
    session.becomingNoisyEventStream.listen((_) => pause());
  }

  Future<void> play() async {
    _userWantsPlayback = true;
    _reconnectTimer?.cancel();
    status = 'Connecting…';
    notifyListeners();
    try {
      await player.play();
    } catch (_) {
      _scheduleReconnect();
    }
  }

  Future<void> pause() async {
    _userWantsPlayback = false;
    _reconnectTimer?.cancel();
    await player.pause();
    status = 'Paused';
    notifyListeners();
  }

  Future<void> stop() async {
    _userWantsPlayback = false;
    _reconnectTimer?.cancel();
    await player.stop();
    status = 'Stopped';
    notifyListeners();
  }

  Future<void> toggle() => playing ? pause() : play();

  Future<void> setVolume(double value) async {
    await player.setVolume(value.clamp(0, 1).toDouble());
    notifyListeners();
  }

  void _scheduleReconnect() {
    if (!_userWantsPlayback) return;
    _reconnectTimer?.cancel();
    _reconnectAttempt = (_reconnectAttempt + 1).clamp(1, 8).toInt();
    final seconds = (1.5 * _reconnectAttempt * _reconnectAttempt).round().clamp(2, 30);
    status = 'Reconnecting in ${seconds}s…';
    notifyListeners();
    _reconnectTimer = Timer(Duration(seconds: seconds), () async {
      if (!_userWantsPlayback) return;
      try {
        await player.load();
        await player.play();
      } catch (_) {
        _scheduleReconnect();
      }
    });
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _stateSub?.cancel();
    _errorSub?.cancel();
    player.dispose();
    super.dispose();
  }
}
