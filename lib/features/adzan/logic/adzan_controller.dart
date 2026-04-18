import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../notification/logic/notification_controller.dart';
import '../data/adzan_repository.dart';
import '../data/models/prayer_time_model.dart';

class AdzanController extends ChangeNotifier {
  AdzanController({
    required AdzanRepository repository,
    required LocalStorage storage,
    required LocationService locationService,
    required NotificationService notificationService,
    required NotificationController notificationController,
  })  : _repository = repository,
        _storage = storage,
        _locationService = locationService,
        _notificationService = notificationService,
        _notificationController = notificationController {
    unawaited(_hydrate());
  }

  static const _masterEnabledKey = 'adzan.master_enabled';
  static const _regularSoundKey = 'adzan.regular_sound';
  static const _fajrSoundKey = 'adzan.fajr_sound';
  static const _offsetMinutesKey = 'adzan.offset_minutes';
  static const _volumeKey = 'adzan.volume';
  static const _preReminderKey = 'adzan.pre_reminder_minutes';
  static const _locationKey = 'adzan.location_label';
  static const _prayerToggleKey = 'adzan.prayer_toggles.v1';
  static const _vibrationEnabledKey = 'adzan.vibration_enabled';
  static const _quietHoursEnabledKey = 'adzan.quiet_hours_enabled';
  static const _quietStartHourKey = 'adzan.quiet_start_hour';
  static const _quietEndHourKey = 'adzan.quiet_end_hour';
  static const _calculationMethodKey = 'adzan.calculation_method';
  static const _madhabKey = 'adzan.madhab';
  static const _exactLocationEnabledKey = 'adzan.exact_location_enabled';
  static const _exactLatitudeKey = 'adzan.exact_latitude';
  static const _exactLongitudeKey = 'adzan.exact_longitude';
  static const _exactUtcOffsetKey = 'adzan.exact_utc_offset';
  static const _exactCountryKey = 'adzan.exact_country';

  final AdzanRepository _repository;
  final LocalStorage _storage;
  final LocationService _locationService;
  final NotificationService _notificationService;
  final NotificationController _notificationController;

  bool _initialized = false;
  bool _masterEnabled = true;
  bool _scheduling = false;
  String _locationLabel = AppConstants.popularLocations.first;
  String _regularSound = AppConstants.defaultRegularAdzanSound;
  String _fajrSound = AppConstants.defaultFajrAdzanSound;
  int _offsetMinutes = 0;
  int _preReminderMinutes = 10;
  double _volume = 1.0;
  bool _vibrationEnabled = true;
  bool _quietHoursEnabled = false;
  int _quietStartHour = 22;
  int _quietEndHour = 5;
  String _calculationMethod = 'Muslim World League';
  String _madhab = 'Shafi\'i';
  String? _error;
  PrayerLocationModel? _exactLocation;
  Map<String, bool> _prayerToggles = <String, bool>{
    'Subuh': true,
    'Zuhur': true,
    'Asar': true,
    'Magrib': true,
    'Isya': true,
  };

  bool get initialized => _initialized;
  bool get masterEnabled => _masterEnabled;
  bool get scheduling => _scheduling;
  String get locationLabel => _locationLabel;
  String get regularSound => _regularSound;
  String get fajrSound => _fajrSound;
  int get offsetMinutes => _offsetMinutes;
  int get preReminderMinutes => _preReminderMinutes;
  double get volume => _volume;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get quietHoursEnabled => _quietHoursEnabled;
  int get quietStartHour => _quietStartHour;
  int get quietEndHour => _quietEndHour;
  String get calculationMethod => _calculationMethod;
  String get madhab => _madhab;
  String? get error => _error;

  PrayerSnapshotModel snapshotFor({
    required String locationLabel,
    required DateTime nowUtc,
  }) {
    return _repository.buildSnapshot(
      locationLabel: locationLabel,
      nowUtc: nowUtc,
      calculationMethod: _calculationMethod,
      madhab: _madhab,
      locationOverride: _exactLocation,
    );
  }

  bool prayerEnabled(String prayerName) => _prayerToggles[prayerName] ?? true;

  Future<void> syncLocation(String label) async {
    if (label == _locationLabel && _initialized) return;
    _locationLabel = label;
    _exactLocation = null;
    await _persist();
    notifyListeners();
    await scheduleUpcomingNotifications();
  }

  Future<String?> detectAndSyncCurrentLocation() async {
    final lookup = await _locationService.detectCurrentLocation();
    if (!lookup.success || lookup.location == null) {
      return lookup.message;
    }
    _locationLabel = lookup.nearestLocation?.label ?? lookup.location!.label;
    _exactLocation = lookup.location;
    await _persist();
    notifyListeners();
    await scheduleUpcomingNotifications();
    return lookup.message;
  }

  Future<String?> syncCustomLocation(String query) async {
    final lookup = await _locationService.resolveManualLocation(query);
    if (!lookup.success || lookup.location == null) {
      return lookup.message;
    }
    _locationLabel = lookup.location!.label;
    _exactLocation = lookup.location;
    await _persist();
    notifyListeners();
    await scheduleUpcomingNotifications();
    return lookup.message;
  }

  Future<void> setMasterEnabled(bool value) async {
    _masterEnabled = value;
    await _persist();
    notifyListeners();
    await scheduleUpcomingNotifications();
  }

  Future<void> setPrayerEnabled(String prayerName, bool value) async {
    _prayerToggles = <String, bool>{
      ..._prayerToggles,
      prayerName: value,
    };
    await _persist();
    notifyListeners();
    await scheduleUpcomingNotifications();
  }

  Future<void> setRegularSound(String value) async {
    _regularSound = AppConstants.normalizeAdzanSound(value);
    await _persist();
    notifyListeners();
    await scheduleUpcomingNotifications();
  }

  Future<void> setFajrSound(String value) async {
    _fajrSound = AppConstants.normalizeAdzanSound(value, fajr: true);
    await _persist();
    notifyListeners();
    await scheduleUpcomingNotifications();
  }

  Future<void> setOffsetMinutes(int value) async {
    _offsetMinutes = value;
    await _persist();
    notifyListeners();
    await scheduleUpcomingNotifications();
  }

  Future<void> setPreReminderMinutes(int value) async {
    _preReminderMinutes = value;
    await _persist();
    notifyListeners();
    await scheduleUpcomingNotifications();
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    await _persist();
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    await _persist();
    notifyListeners();
    await scheduleUpcomingNotifications();
  }

  Future<void> setQuietHoursEnabled(bool value) async {
    _quietHoursEnabled = value;
    await _persist();
    notifyListeners();
    await scheduleUpcomingNotifications();
  }

  Future<void> setQuietWindow({
    int? startHour,
    int? endHour,
  }) async {
    _quietStartHour = startHour ?? _quietStartHour;
    _quietEndHour = endHour ?? _quietEndHour;
    await _persist();
    notifyListeners();
    await scheduleUpcomingNotifications();
  }

  Future<void> setCalculationMethod(String value) async {
    _calculationMethod = value;
    await _persist();
    notifyListeners();
    await scheduleUpcomingNotifications();
  }

  Future<void> setMadhab(String value) async {
    _madhab = value;
    await _persist();
    notifyListeners();
    await scheduleUpcomingNotifications();
  }

  Future<void> scheduleUpcomingNotifications() async {
    if (!_initialized) return;
    _scheduling = true;
    _error = null;
    notifyListeners();

    try {
      await _notificationService.cancelAll();
      if (!_masterEnabled) {
        _scheduling = false;
        notifyListeners();
        return;
      }

      final nowUtc = DateTime.now().toUtc();
      final items = <ScheduledNotificationInput>[];

      for (var dayOffset = 0; dayOffset < 7; dayOffset += 1) {
        final dayUtc = nowUtc.add(Duration(days: dayOffset));
        await _repository.primeRemoteSnapshot(
          locationLabel: _locationLabel,
          nowUtc: dayUtc,
          calculationMethod: _calculationMethod,
          madhab: _madhab,
          locationOverride: _exactLocation,
        );
        final snapshot = _repository.buildSnapshot(
          locationLabel: _locationLabel,
          nowUtc: dayUtc,
          calculationMethod: _calculationMethod,
          madhab: _madhab,
          locationOverride: _exactLocation,
        );

        for (var index = 0; index < snapshot.prayers.length; index += 1) {
          final prayer = snapshot.prayers[index];
          if (!prayerEnabled(prayer.name)) continue;

          final scheduledTime = _toDeviceLocalTime(
            prayer.time,
            snapshot.location,
          ).add(Duration(minutes: _offsetMinutes));
          if (!scheduledTime.isAfter(DateTime.now())) {
            continue;
          }
          if (_isWithinQuietHours(scheduledTime)) {
            continue;
          }

          final soundName = prayer.name == 'Subuh'
              ? AppConstants.normalizeAdzanSound(_fajrSound, fajr: true)
              : AppConstants.normalizeAdzanSound(_regularSound);
          final rawSound = AppConstants.adzanRawResourceNames[soundName] ??
              AppConstants
                  .adzanRawResourceNames[AppConstants.defaultRegularAdzanSound];
          items.add(
            ScheduledNotificationInput(
              id: _notificationId(scheduledTime, index, reminder: false),
              title: 'Waktu ${prayer.name}',
              body:
                  'Adzan ${prayer.name} untuk ${snapshot.location.label} sudah masuk.',
              when: scheduledTime,
              payload:
                  'adzan:${prayer.name}:${_notificationId(scheduledTime, index, reminder: false)}',
              channelId: _channelIdForSound(soundName),
              channelName: 'Adzan $soundName',
              channelDescription: 'Notifikasi adzan Muslimku',
              soundRawResource: rawSound,
              enableVibration: _vibrationEnabled,
              volume: _volume,
            ),
          );

          if (_preReminderMinutes > 0) {
            final reminderTime =
                scheduledTime.subtract(Duration(minutes: _preReminderMinutes));
            if (reminderTime.isAfter(DateTime.now())) {
              items.add(
                ScheduledNotificationInput(
                  id: _notificationId(scheduledTime, index, reminder: true),
                  title: '${prayer.name} dalam $_preReminderMinutes menit',
                  body:
                      'Siapkan diri untuk ${prayer.name} di ${snapshot.location.label}.',
                  when: reminderTime,
                  payload:
                      'reminder:${prayer.name}:${_notificationId(scheduledTime, index, reminder: true)}',
                  channelId: 'adzan_reminders',
                  channelName: 'Adzan Reminders',
                  channelDescription: 'Pengingat sebelum adzan',
                  enableVibration: _vibrationEnabled,
                ),
              );
            }
          }
        }
      }

      await _notificationService.scheduleNotifications(items);
      await _notificationController.syncScheduledNotifications(items);
    } catch (error) {
      _error = error.toString();
    } finally {
      _scheduling = false;
      notifyListeners();
    }
  }

  Future<void> _hydrate() async {
    await _storage.init();

    _masterEnabled = _storage.getBool(_masterEnabledKey) ?? true;
    _regularSound = AppConstants.normalizeAdzanSound(
      _storage.getString(_regularSoundKey),
    );
    _fajrSound = AppConstants.normalizeAdzanSound(
      _storage.getString(_fajrSoundKey),
      fajr: true,
    );
    _offsetMinutes = _storage.getInt(_offsetMinutesKey) ?? 0;
    _preReminderMinutes = _storage.getInt(_preReminderKey) ?? 10;
    _volume = _storage.getDouble(_volumeKey) ?? 1.0;
    _vibrationEnabled = _storage.getBool(_vibrationEnabledKey) ?? true;
    _quietHoursEnabled = _storage.getBool(_quietHoursEnabledKey) ?? false;
    _quietStartHour = _storage.getInt(_quietStartHourKey) ?? 22;
    _quietEndHour = _storage.getInt(_quietEndHourKey) ?? 5;
    _calculationMethod =
        _storage.getString(_calculationMethodKey) ?? 'Muslim World League';
    _madhab = _storage.getString(_madhabKey) ?? 'Shafi\'i';
    _locationLabel =
        _storage.getString(_locationKey) ?? AppConstants.popularLocations.first;
    final exactEnabled = _storage.getBool(_exactLocationEnabledKey) ?? false;
    final exactLatitude = _storage.getDouble(_exactLatitudeKey);
    final exactLongitude = _storage.getDouble(_exactLongitudeKey);
    final exactUtcOffset = _storage.getDouble(_exactUtcOffsetKey);
    if (exactEnabled &&
        exactLatitude != null &&
        exactLongitude != null &&
        exactUtcOffset != null) {
      _exactLocation = PrayerLocationModel(
        label: _locationLabel,
        country: _storage.getString(_exactCountryKey) ?? 'GPS',
        latitude: exactLatitude,
        longitude: exactLongitude,
        utcOffsetHours: exactUtcOffset,
        isExact: true,
      );
    } else {
      _exactLocation = null;
    }

    final rawToggles = _storage.getJsonMap(_prayerToggleKey);
    if (rawToggles != null && rawToggles.isNotEmpty) {
      _prayerToggles = rawToggles.map(
        (key, value) => MapEntry(key, value == true),
      );
    }

    _initialized = true;
    notifyListeners();
    await scheduleUpcomingNotifications();
  }

  Future<void> reload() async {
    _initialized = false;
    notifyListeners();
    await _hydrate();
  }

  Future<void> snoozePrayerAlert({
    required String prayerName,
    Duration duration = const Duration(minutes: 5),
  }) async {
    final soundName = prayerName == 'Subuh'
        ? AppConstants.normalizeAdzanSound(_fajrSound, fajr: true)
        : AppConstants.normalizeAdzanSound(_regularSound);
    final when = DateTime.now().add(duration);
    final id = when.millisecondsSinceEpoch.remainder(1 << 31);
    final item = ScheduledNotificationInput(
      id: id,
      title: '$prayerName ditunda ${duration.inMinutes} menit',
      body: 'Pengingat ulang untuk $prayerName di $_locationLabel.',
      when: when,
      payload: 'reminder:$prayerName:$id',
      channelId: _channelIdForSound(soundName),
      channelName: 'Adzan $soundName',
      channelDescription: 'Pengingat ulang adzan Muslimku',
      soundRawResource: AppConstants.adzanRawResourceNames[soundName] ??
          AppConstants
              .adzanRawResourceNames[AppConstants.defaultRegularAdzanSound],
      enableVibration: _vibrationEnabled,
      volume: _volume,
    );
    await _notificationService
        .scheduleNotifications(<ScheduledNotificationInput>[item]);
    await _notificationController.recordInstantNotification(
      id: 'snooze_$id',
      title: item.title,
      body: item.body,
      category: 'reminder',
      payload: item.payload,
      routeName: 'adzan-alert',
      routeStringArgument: item.payload,
    );
  }

  Future<void> _persist() async {
    await _storage.setBool(_masterEnabledKey, _masterEnabled);
    await _storage.setString(_regularSoundKey, _regularSound);
    await _storage.setString(_fajrSoundKey, _fajrSound);
    await _storage.setInt(_offsetMinutesKey, _offsetMinutes);
    await _storage.setInt(_preReminderKey, _preReminderMinutes);
    await _storage.setDouble(_volumeKey, _volume);
    await _storage.setBool(_vibrationEnabledKey, _vibrationEnabled);
    await _storage.setBool(_quietHoursEnabledKey, _quietHoursEnabled);
    await _storage.setInt(_quietStartHourKey, _quietStartHour);
    await _storage.setInt(_quietEndHourKey, _quietEndHour);
    await _storage.setString(_calculationMethodKey, _calculationMethod);
    await _storage.setString(_madhabKey, _madhab);
    await _storage.setString(_locationKey, _locationLabel);
    await _storage.setBool(_exactLocationEnabledKey, _exactLocation != null);
    if (_exactLocation == null) {
      await _storage.remove(_exactLatitudeKey);
      await _storage.remove(_exactLongitudeKey);
      await _storage.remove(_exactUtcOffsetKey);
      await _storage.remove(_exactCountryKey);
    } else {
      await _storage.setDouble(_exactLatitudeKey, _exactLocation!.latitude);
      await _storage.setDouble(_exactLongitudeKey, _exactLocation!.longitude);
      await _storage.setDouble(
        _exactUtcOffsetKey,
        _exactLocation!.utcOffsetHours,
      );
      await _storage.setString(_exactCountryKey, _exactLocation!.country);
    }
    await _storage.setJsonMap(
      _prayerToggleKey,
      _prayerToggles.map((key, value) => MapEntry(key, value)),
    );
  }

  Future<void> stopActiveAlert() async {
    await _notificationService.stopAdhanPlayback();
  }

  int _notificationId(
    DateTime scheduledTime,
    int prayerIndex, {
    required bool reminder,
  }) {
    final date = scheduledTime.year * 10000 +
        scheduledTime.month * 100 +
        scheduledTime.day;
    final slot = prayerIndex * 2 + (reminder ? 1 : 0);
    return date * 100 + slot;
  }

  DateTime _toDeviceLocalTime(
    DateTime prayerWallClock,
    PrayerLocationModel location,
  ) {
    final utcInstant = DateTime.utc(
      prayerWallClock.year,
      prayerWallClock.month,
      prayerWallClock.day,
      prayerWallClock.hour,
      prayerWallClock.minute,
      prayerWallClock.second,
    ).subtract(
      Duration(minutes: (location.utcOffsetHours * 60).round()),
    );
    return utcInstant.toLocal();
  }

  String _channelIdForSound(String soundName) {
    return 'adzan_${soundName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}';
  }

  bool _isWithinQuietHours(DateTime scheduledTime) {
    if (!_quietHoursEnabled) return false;
    final hour = scheduledTime.hour;
    if (_quietStartHour == _quietEndHour) {
      return true;
    }
    if (_quietStartHour < _quietEndHour) {
      return hour >= _quietStartHour && hour < _quietEndHour;
    }
    return hour >= _quietStartHour || hour < _quietEndHour;
  }
}
