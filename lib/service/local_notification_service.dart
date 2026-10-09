import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:menarmed_mobile/service/push_notification_service.dart';

class LocalNotificationService {
  static const messageChannel = AndroidNotificationChannel(
    'menarmed_messages_v1',
    'Pesan Menarmed',
    importance: Importance.high,
  );
  static const alarmChannel = AndroidNotificationChannel(
    'stelling_siren_v1',
    'Alarm Stelling',
    description: 'Pemberitahuan siaga dengan suara sirene',
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('alarm'),
    playSound: true,
  );
  LocalNotificationService._privateConstructor();
  static final LocalNotificationService instance =
      LocalNotificationService._privateConstructor();

  final _localNotificationService = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _localNotificationService.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
    await _localNotificationService
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(alarmChannel);
    await _localNotificationService
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(messageChannel);
  }

  Future<NotificationDetails> _notificationDetail() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          "stelling_siren_v1",
          "Alarm Stelling",
          channelDescription: "Pemberitahuan siaga dengan suara sirene",
          sound: RawResourceAndroidNotificationSound('alarm'),
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    return const NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool siren = true,
  }) async {
    final details = siren
        ? await _notificationDetail()
        : const NotificationDetails(
            android: AndroidNotificationDetails(
              'menarmed_messages_v1',
              'Pesan Menarmed',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          );
    await _localNotificationService.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      PushNotificationService.open(
        Map<String, dynamic>.from(jsonDecode(response.payload!)),
      );
    } catch (_) {}
  }
}
