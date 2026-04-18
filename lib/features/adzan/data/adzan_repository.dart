import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'models/prayer_time_model.dart';

class AdzanRepository {
  const AdzanRepository();

  static const double _sunAltitude = 0.833;
  static const double _makkahLat = 21.4225;
  static const double _makkahLng = 39.8262;

  PrayerSnapshotModel buildSnapshot({
    required String locationLabel,
    required DateTime nowUtc,
    String calculationMethod = 'Muslim World League',
    String madhab = 'Shafi\'i',
    PrayerLocationModel? locationOverride,
  }) {
    final location =
        locationOverride ?? PrayerLocationModel.byLabel(locationLabel);
    final locationNow = nowUtc.add(
      Duration(minutes: (location.utcOffsetHours * 60).round()),
    );
    final prayers = _calculatePrayerTimes(
      location,
      locationNow,
      calculationMethod: calculationMethod,
      madhab: madhab,
    );
    final nextPrayer = _resolveNextPrayer(prayers, locationNow);
    final qiblaBearing = _calculateQiblaBearing(location);
    final distance = _calculateDistanceToMakkah(location);

    return PrayerSnapshotModel(
      location: location,
      locationNow: locationNow,
      prayers: prayers,
      nextPrayer: nextPrayer,
      remaining: nextPrayer.time.difference(locationNow),
      qiblaBearing: qiblaBearing,
      distanceToMakkahKm: distance,
    );
  }

  List<PrayerTimeModel> _calculatePrayerTimes(
    PrayerLocationModel location,
    DateTime locationNow, {
    required String calculationMethod,
    required String madhab,
  }) {
    final date = DateTime(locationNow.year, locationNow.month, locationNow.day);
    final dayOfYear = _dayOfYear(date);
    final equation = _equationOfTime(dayOfYear);
    final declination = _solarDeclination(dayOfYear);
    final profile = _profileForMethod(calculationMethod);
    final asrShadowFactor = _shadowFactorForMadhab(madhab);

    final dhuhrHour =
        12 + location.utcOffsetHours - (location.longitude / 15) - equation;
    final sunriseDelta =
        _hourAngle(location.latitude, declination, 90 + _sunAltitude);
    final fajrDelta =
        _hourAngle(location.latitude, declination, 90 + profile.fajrAngle);
    final ishaDelta = profile.usesFixedIshaMinutes
        ? profile.ishaMinutesAfterMaghrib / 60
        : _hourAngle(location.latitude, declination, 90 + profile.ishaAngle);
    final asrDelta = _asrHourAngle(
      location.latitude,
      declination,
      shadowFactor: asrShadowFactor,
    );

    final items = <PrayerTimeModel>[
      PrayerTimeModel(
        name: 'Subuh',
        time: _dateWithHourValue(date, dhuhrHour - fajrDelta),
        icon: Icons.nights_stay_outlined,
        isActive: false,
      ),
      PrayerTimeModel(
        name: 'Zuhur',
        time: _dateWithHourValue(date, dhuhrHour),
        icon: Icons.wb_sunny_outlined,
        isActive: false,
      ),
      PrayerTimeModel(
        name: 'Asar',
        time: _dateWithHourValue(date, dhuhrHour + asrDelta),
        icon: Icons.sunny,
        isActive: false,
      ),
      PrayerTimeModel(
        name: 'Magrib',
        time: _dateWithHourValue(date, dhuhrHour + sunriseDelta),
        icon: Icons.wb_twilight_outlined,
        isActive: false,
      ),
      PrayerTimeModel(
        name: 'Isya',
        time: _dateWithHourValue(date, dhuhrHour + ishaDelta),
        icon: Icons.bedtime_outlined,
        isActive: false,
      ),
    ];

    PrayerTimeModel? active;
    for (final prayer in items) {
      if (prayer.time.isAfter(locationNow)) {
        active = prayer;
        break;
      }
    }

    return items
        .map(
          (prayer) => PrayerTimeModel(
            name: prayer.name,
            time: prayer.time,
            icon: prayer.icon,
            isActive: active?.name == prayer.name,
          ),
        )
        .toList();
  }

  PrayerTimeModel _resolveNextPrayer(
    List<PrayerTimeModel> prayers,
    DateTime locationNow,
  ) {
    for (final prayer in prayers) {
      if (prayer.time.isAfter(locationNow)) return prayer;
    }
    final first = prayers.first;
    return PrayerTimeModel(
      name: first.name,
      time: first.time.add(const Duration(days: 1)),
      icon: first.icon,
      isActive: true,
    );
  }

  int _dayOfYear(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    return date.difference(start).inDays + 1;
  }

  double _solarDeclination(int dayOfYear) {
    final gamma = (2 * math.pi / 365) * (dayOfYear - 1);
    return 0.006918 -
        0.399912 * math.cos(gamma) +
        0.070257 * math.sin(gamma) -
        0.006758 * math.cos(2 * gamma) +
        0.000907 * math.sin(2 * gamma) -
        0.002697 * math.cos(3 * gamma) +
        0.00148 * math.sin(3 * gamma);
  }

  double _equationOfTime(int dayOfYear) {
    final gamma = (2 * math.pi / 365) * (dayOfYear - 1);
    final minutes = 229.18 *
        (0.000075 +
            0.001868 * math.cos(gamma) -
            0.032077 * math.sin(gamma) -
            0.014615 * math.cos(2 * gamma) -
            0.040849 * math.sin(2 * gamma));
    return minutes / 60;
  }

  double _hourAngle(double latitude, double declination, double zenithDegrees) {
    final latRad = PrayerSnapshotModel.degToRad(latitude);
    final zenithRad = PrayerSnapshotModel.degToRad(zenithDegrees);
    final cosValue =
        (math.cos(zenithRad) - math.sin(latRad) * math.sin(declination)) /
            (math.cos(latRad) * math.cos(declination));
    final clamped = cosValue.clamp(-1.0, 1.0);
    return PrayerSnapshotModel.radToDeg(math.acos(clamped)) / 15;
  }

  double _asrHourAngle(
    double latitude,
    double declination, {
    required double shadowFactor,
  }) {
    final latRad = PrayerSnapshotModel.degToRad(latitude);
    final angle = -math.atan(
      1 / (shadowFactor + math.tan((latRad - declination).abs())),
    );
    final cosValue =
        (math.sin(angle) - math.sin(latRad) * math.sin(declination)) /
            (math.cos(latRad) * math.cos(declination));
    final clamped = cosValue.clamp(-1.0, 1.0);
    return PrayerSnapshotModel.radToDeg(math.acos(clamped)) / 15;
  }

  DateTime _dateWithHourValue(DateTime date, double hourValue) {
    final totalSeconds = (hourValue * 3600).round();
    final normalizedSeconds = ((totalSeconds % 86400) + 86400) % 86400;
    return date.add(Duration(seconds: normalizedSeconds));
  }

  double _calculateQiblaBearing(PrayerLocationModel location) {
    final lat1 = PrayerSnapshotModel.degToRad(location.latitude);
    final lng1 = PrayerSnapshotModel.degToRad(location.longitude);
    final lat2 = PrayerSnapshotModel.degToRad(_makkahLat);
    final lng2 = PrayerSnapshotModel.degToRad(_makkahLng);
    final deltaLng = lng2 - lng1;

    final y = math.sin(deltaLng);
    final x =
        math.cos(lat1) * math.tan(lat2) - math.sin(lat1) * math.cos(deltaLng);
    final bearing = PrayerSnapshotModel.radToDeg(math.atan2(y, x));
    return (bearing + 360) % 360;
  }

  double _calculateDistanceToMakkah(PrayerLocationModel location) {
    const earthRadiusKm = 6371.0;
    final lat1 = PrayerSnapshotModel.degToRad(location.latitude);
    final lng1 = PrayerSnapshotModel.degToRad(location.longitude);
    final lat2 = PrayerSnapshotModel.degToRad(_makkahLat);
    final lng2 = PrayerSnapshotModel.degToRad(_makkahLng);
    final deltaLat = lat2 - lat1;
    final deltaLng = lng2 - lng1;

    final a = math.pow(math.sin(deltaLat / 2), 2) +
        math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(deltaLng / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  _MethodProfile _profileForMethod(String method) {
    switch (method) {
      case 'Kementerian Agama RI':
        return const _MethodProfile(fajrAngle: 20.0, ishaAngle: 18.0);
      case 'Umm al-Qura':
        return const _MethodProfile(
          fajrAngle: 18.5,
          ishaAngle: 0,
          usesFixedIshaMinutes: true,
          ishaMinutesAfterMaghrib: 90,
        );
      case 'Egyptian General Authority':
        return const _MethodProfile(fajrAngle: 19.5, ishaAngle: 17.5);
      case 'Muslim World League':
      default:
        return const _MethodProfile(fajrAngle: 18.0, ishaAngle: 17.0);
    }
  }

  double _shadowFactorForMadhab(String madhab) {
    switch (madhab) {
      case 'Hanafi':
        return 2.0;
      case 'Maliki':
      case 'Hanbali':
      case 'Shafi\'i':
      default:
        return 1.0;
    }
  }
}

class _MethodProfile {
  const _MethodProfile({
    required this.fajrAngle,
    required this.ishaAngle,
    this.usesFixedIshaMinutes = false,
    this.ishaMinutesAfterMaghrib = 90,
  });

  final double fajrAngle;
  final double ishaAngle;
  final bool usesFixedIshaMinutes;
  final int ishaMinutesAfterMaghrib;
}
