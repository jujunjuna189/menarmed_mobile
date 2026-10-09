import 'dart:async';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:menarmed_mobile/utils/api.dart';

class PushTokenService with WidgetsBindingObserver {
  static final instance = PushTokenService();
  bool _initialized = false;
  bool _loggingOut = false;
  Future<void> _queue = Future.value();

  void initialize() {
    if (_initialized ||
        kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (_) => sync(),
      onError: (_) => debugPrint('FCM token refresh unavailable'),
    );
    unawaited(sync());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(sync());
  }

  Future<String> _installation(SharedPreferences prefs) async {
    final saved = prefs.getString('push_installation_id');
    if (saved != null) return saved;
    final random = Random.secure();
    final id = List.generate(
      32,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    await prefs.setString('push_installation_id', id);
    return id;
  }

  Future<void> sync() {
    if (!_initialized || _loggingOut) return Future.value();
    _queue = _queue.then((_) async {
      if (_loggingOut) return;
      try {
        final prefs = await SharedPreferences.getInstance();
        final auth = prefs.getString('auth_token');
        if (auth == null || auth.isEmpty) return;
        final token = await FirebaseMessaging.instance.getToken();
        if (token == null || _loggingOut) return;
        final id = await _installation(prefs);
        final response = await http
            .post(
              Uri.parse('${Api.server}api/push-device'),
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $auth',
              },
              body: {'installation_id': id, 'token': token},
            )
            .timeout(const Duration(seconds: 10));
        if (response.statusCode != 200) {
          debugPrint('FCM sync failed: HTTP ${response.statusCode}');
        }
      } catch (_) {
        debugPrint('FCM sync unavailable; retry on next login or resume');
      }
    });
    return _queue;
  }

  void signedIn() {
    _loggingOut = false;
    initialize();
    unawaited(sync());
  }

  Future<void> unregister() async {
    _loggingOut = true;
    await _queue;
    try {
      final prefs = await SharedPreferences.getInstance();
      final auth = prefs.getString('auth_token');
      final id = prefs.getString('push_installation_id');
      if (auth == null || id == null) return;
      final response = await http
          .delete(
            Uri.parse('${Api.server}api/push-device'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $auth',
            },
            body: {'installation_id': id},
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 204) {
        debugPrint('FCM unregister failed: HTTP ${response.statusCode}');
      }
    } catch (_) {
      debugPrint('FCM unregister unavailable');
    }
  }
}
