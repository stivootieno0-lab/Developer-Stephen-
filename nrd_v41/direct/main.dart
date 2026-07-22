import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'app_state.dart';
import 'branded_screens.dart';
import 'nrd_theme.dart';
import 'radio_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId:'com.nationalrevivaldesk.radio.live',
    androidNotificationChannelName:'Jesus is LORD Radio',
    androidNotificationOngoing:true,
  );
  await NrdRadioController.instance.initialise();
  final state=AppState();
  await state.initialise();
  runApp(NrdApp(state:state));
}

class NrdApp extends StatelessWidget {
  const NrdApp({super.key,required this.state});
  final AppState state;
  @override Widget build(BuildContext context)=>AnimatedBuilder(animation:state,builder:(_,__)=>MaterialApp(debugShowCheckedModeBanner:false,title:'National Revival Desk',theme:buildNrdTheme(),home:state.token.isEmpty?LoginPage(state:state):HomePage(state:state)));
}
