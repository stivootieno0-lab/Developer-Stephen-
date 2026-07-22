import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'catalog.dart';

class AppState extends ChangeNotifier {
  static const baseUrl = 'https://www.nationalrevivaldesk.com';
  static const _queueKey = 'nrd_v4_queue';
  static const _tokenKey = 'nrd_v4_token';
  String token = '';
  bool busy = false;
  bool online = true;
  DateTime? lastSync;
  List<RevivalCategory> categories = defaultCategories;
  List<Map<String, dynamic>> queue = [];

  Future<void> initialise() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_tokenKey) ?? '';
    queue = (jsonDecode(prefs.getString(_queueKey) ?? '[]') as List).map((e) => Map<String,dynamic>.from(e as Map)).toList();
    Connectivity().onConnectivityChanged.listen((r) { online = !r.contains(ConnectivityResult.none); notifyListeners(); if (online) sync(); });
    final current = await Connectivity().checkConnectivity(); online = !current.contains(ConnectivityResult.none);
    if (online) { await refreshCategories(); await sync(); }
    notifyListeners();
  }

  Future<Map<String,dynamic>> _request(String method, String path, [Map<String,dynamic>? body]) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String,String>{'Accept':'application/json','Content-Type':'application/json'};
    if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    final response = method == 'GET' ? await http.get(uri, headers: headers) : await http.post(uri, headers: headers, body: jsonEncode(body ?? {}));
    final data = response.body.isEmpty ? <String,dynamic>{} : Map<String,dynamic>.from(jsonDecode(response.body) as Map);
    if (response.statusCode >= 400) throw Exception('${data['message'] ?? 'Request failed (${response.statusCode})'}');
    return data;
  }

  Future<void> login(String email, String password) async {
    busy = true; notifyListeners();
    try { final data = await _request('POST','/api/mobile_login.php',{'email':email,'password':password,'app_version':'4.0.0'}); token = '${data['token'] ?? ''}'; final p=await SharedPreferences.getInstance(); await p.setString(_tokenKey, token); }
    finally { busy = false; notifyListeners(); }
  }

  Future<void> logout() async { token=''; final p=await SharedPreferences.getInstance(); await p.remove(_tokenKey); notifyListeners(); }

  Future<void> refreshCategories() async {
    try {
      final data = await _request('GET','/api/v1/activity-categories?per_page=100');
      final list = (data['data'] as List? ?? const []).map((e)=>RevivalCategory.fromJson(Map<String,dynamic>.from(e as Map))).where((e)=>e.id>0).toList();
      if (list.isNotEmpty) categories=list;
    } catch (_) { categories=defaultCategories; }
    notifyListeners();
  }

  Future<void> enqueue(String type, Map<String,dynamic> payload) async {
    queue.add({'local_id':const Uuid().v4(),'type':type,'payload':payload,'status':'pending','created_at':DateTime.now().toIso8601String()});
    await _saveQueue(); notifyListeners(); if (online && token.isNotEmpty) await sync();
  }

  Future<void> retry(String id) async { final item=queue.firstWhere((e)=>e['local_id']==id); item['status']='pending'; await _saveQueue(); await sync(); }
  Future<void> remove(String id) async { queue.removeWhere((e)=>e['local_id']==id); await _saveQueue(); notifyListeners(); }

  Future<void> sync() async {
    if (!online || token.isEmpty || busy) return;
    busy=true; notifyListeners();
    for (final item in List<Map<String,dynamic>>.from(queue)) {
      if (item['status']=='synced') continue;
      try {
        final endpoint=item['type']=='plan' ? '/api/v1/mobile/plans' : '/api/v1/mobile/reports';
        await _request('POST',endpoint,{...Map<String,dynamic>.from(item['payload'] as Map),'idempotency_key':item['local_id']});
        item['status']='synced';
      } catch (e) { item['status']='failed'; item['error']=e.toString(); }
    }
    queue.removeWhere((e)=>e['status']=='synced'); lastSync=DateTime.now(); busy=false; await _saveQueue(); notifyListeners();
  }

  Future<void> _saveQueue() async { final p=await SharedPreferences.getInstance(); await p.setString(_queueKey,jsonEncode(queue)); }
}
