import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../routes/app_navigator.dart';
import '../../routes/route_names.dart';

class ScheduledNotificationInput {
  const ScheduledNotificationInput({
    required this.id,
    required this.title,
    required this.body,
    required this.when,
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
    this.soundRawResource,
    this.payload,
    this.enableVibration = true,
    this.volume = 1.0,
  });

  final int id;
  final String title;
  final String body;
  final DateTime when;
  final String channelId;
  final String channelName;
  final String channelDescription;
  final String? soundRawResource;
  final String? payload;
  final bool enableVibration;
  final double volume;
}

class NotificationService {
  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const MethodChannel _nativeAdhanChannel =
      MethodChannel('com.muslimku.app/adhan_alarm');
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  void Function(String? payload)? _onTap;

  Future<void> initialize({
    void Function(String? payload)? onTap,
  }) async {
    _onTap = onTap ?? _onTap;
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.local);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (details) {
        if (_onTap != null) {
          _onTap?.call(details.payload);
          return;
        }
        _handleDefaultTap(details.payload);
      },
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final notificationsGranted =
        await android?.requestNotificationsPermission() ?? true;
    await android?.requestExactAlarmsPermission();
    return notificationsGranted;
  }

  Future<void> cancel(int id) async {
    await initialize();
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
    await _cancelNativeAdhanAlarms();
  }

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      payload: payload,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'muslimku_general',
          'Muslimku General',
          channelDescription: 'General Muslimku notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> scheduleNotifications(
    List<ScheduledNotificationInput> items,
  ) async {
    await initialize();
    final nativeAdhanItems = items
        .where((item) => (item.soundRawResource ?? '').isNotEmpty)
        .toList();
    final nativeScheduled = await _scheduleNativeAdhanAlarms(nativeAdhanItems);
    final pluginItems = items.where((item) {
      if ((item.soundRawResource ?? '').isEmpty) {
        return true;
      }
      return !nativeScheduled;
    }).toList();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    for (final item in pluginItems) {
      final channel = AndroidNotificationChannel(
        item.channelId,
        item.channelName,
        description: item.channelDescription,
        importance: Importance.max,
        playSound: item.soundRawResource != null,
        enableVibration: item.enableVibration,
        sound: item.soundRawResource == null
            ? null
            : RawResourceAndroidNotificationSound(item.soundRawResource!),
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );
      await android?.createNotificationChannel(channel);

      await _plugin.zonedSchedule(
        id: item.id,
        title: item.title,
        body: item.body,
        scheduledDate: tz.TZDateTime.from(item.when, tz.local),
        payload: item.payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            item.channelId,
            item.channelName,
            channelDescription: item.channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            category: AndroidNotificationCategory.alarm,
            playSound: item.soundRawResource != null,
            enableVibration: item.enableVibration,
            sound: item.soundRawResource == null
                ? null
                : RawResourceAndroidNotificationSound(item.soundRawResource!),
            fullScreenIntent: true,
            visibility: NotificationVisibility.public,
          ),
        ),
      );
    }
  }

  Future<void> stopAdhanPlayback() async {
    try {
      await _nativeAdhanChannel.invokeMethod<void>('stopAdhanPlayback');
    } catch (_) {
      // Ignore on unsupported platforms.
    }
  }

  Future<bool> previewAdhanSound({
    required String soundRawResource,
    double volume = 1.0,
  }) async {
    try {
      final result = await _nativeAdhanChannel.invokeMethod<bool>(
        'previewAdhanSound',
        <String, dynamic>{
          'soundRawResource': soundRawResource,
          'volume': volume,
        },
      );
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _scheduleNativeAdhanAlarms(
    List<ScheduledNotificationInput> items,
  ) async {
    try {
      await _nativeAdhanChannel.invokeMethod<void>(
        'scheduleAdhanAlarms',
        <String, dynamic>{
          'alarms': items
              .map(
                (item) => <String, dynamic>{
                  'id': item.id,
                  'title': item.title,
                  'body': item.body,
                  'whenEpochMs': item.when.millisecondsSinceEpoch,
                  'channelId': item.channelId,
                  'channelName': item.channelName,
                  'channelDescription': item.channelDescription,
                  'soundRawResource': item.soundRawResource,
                  'payload': item.payload,
                  'enableVibration': item.enableVibration,
                  'volume': item.volume,
                },
              )
              .toList(),
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _cancelNativeAdhanAlarms() async {
    try {
      await _nativeAdhanChannel.invokeMethod<void>('cancelAdhanAlarms');
    } catch (_) {
      // Ignore on unsupported platforms.
    }
  }

  void _handleDefaultTap(String? payload) {
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;
    if ((payload ?? '').startsWith('adzan:') ||
        (payload ?? '').startsWith('reminder:')) {
      navigator.pushNamed(RouteNames.adzanAlert);
      return;
    }
    navigator.pushNamed(RouteNames.notifications);
  }
}
