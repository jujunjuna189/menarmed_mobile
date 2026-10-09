import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:menarmed_mobile/model/alarm_description_model.dart';
import 'package:menarmed_mobile/service/local_notification_service.dart';

class PushNotificationService {
  static const topic = 'stelling_alarm';
  static final navigatorKey = GlobalKey<NavigatorState>();
  static Map<String, dynamic>? _pending;
  static bool navigationReady = false;
  static void open(Map<String, dynamic> data) {
    final code = int.tryParse(data['code']?.toString() ?? '');
    final alarms = AlarmDescriptionModel.instance.alarmDescription;
    final isMessage = data['type'] == 'push_message';
    if (!isMessage && (code == null || code < 0 || code >= alarms.length)) {
      return;
    }
    if (!navigationReady || navigatorKey.currentState == null) {
      _pending = data;
      return;
    }
    if (isMessage) {
      showDialog<void>(
        context: navigatorKey.currentState!.context,
        builder: (context) => AlertDialog(
          title: Text(data['title']?.toString() ?? 'Notifikasi'),
          content: SingleChildScrollView(
            child: Text(data['body']?.toString() ?? ''),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
      return;
    }
    navigatorKey.currentState!.pushNamed(
      '/alarm_description',
      arguments: jsonEncode({
        ...alarms[code!],
        'content': alarms[code]['description'],
      }),
    );
  }

  static void ready() {
    navigationReady = true;
    final data = _pending;
    _pending = null;
    if (data != null) open(data);
  }

  static Future<void> initialize() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    await messaging.subscribeToTopic(topic);
    await messaging.subscribeToTopic('menarmed_all');
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => open(message.data),
    );
    final initial = await messaging.getInitialMessage();
    if (initial != null) _pending = initial.data;
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      LocalNotificationService.instance.showNotification(
        id: 7001,
        title: notification.title ?? 'Alarm Stelling',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
        siren: message.data['siren'] != '0',
      );
    });
  }
}
