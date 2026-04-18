import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/location_catalog.dart';

class PrayerMoment {
  const PrayerMoment({
    required this.name,
    required this.time,
    required this.icon,
    this.isActive = false,
  });

  final String name;
  final DateTime time;
  final IconData icon;
  final bool isActive;
}

class PrayerScheduleSnapshot {
  const PrayerScheduleSnapshot({
    required this.location,
    required this.locationNow,
    required this.prayers,
    required this.nextPrayer,
    required this.remaining,
    required this.qiblaBearing,
    required this.distanceToMakkahKm,
  });

  final AppLocationData location;
  final DateTime locationNow;
  final List<PrayerMoment> prayers;
  final PrayerMoment nextPrayer;
  final Duration remaining;
  final double qiblaBearing;
  final double distanceToMakkahKm;
}

class SpiritualGuidanceService {
  static const double _fajrAngle = 18.0;
  static const double _ishaAngle = 17.0;
  static const double _sunAltitude = 0.833;
  static const double _makkahLat = 21.4225;
  static const double _makkahLng = 39.8262;

  static PrayerScheduleSnapshot buildSnapshot({
    required AppLocationData location,
    required DateTime nowUtc,
  }) {
    final locationNow = nowUtc.add(Duration(hours: location.utcOffsetHours));
    final prayerTimes = _calculatePrayerTimes(location, locationNow);
    final nextPrayer = _resolveNextPrayer(prayerTimes, locationNow);
    final qiblaBearing = _calculateQiblaBearing(location);
    final distance = _calculateDistanceToMakkah(location);

    return PrayerScheduleSnapshot(
      location: location,
      locationNow: locationNow,
      prayers: prayerTimes,
      nextPrayer: nextPrayer,
      remaining: nextPrayer.time.difference(locationNow),
      qiblaBearing: qiblaBearing,
      distanceToMakkahKm: distance,
    );
  }

  static List<PrayerMoment> _calculatePrayerTimes(
    AppLocationData location,
    DateTime locationNow,
  ) {
    final date = DateTime(locationNow.year, locationNow.month, locationNow.day);
    final dayOfYear = _dayOfYear(date);
    final equation = _equationOfTime(dayOfYear);
    final declination = _solarDeclination(dayOfYear);

    final dhuhrHour =
        12 + location.utcOffsetHours - (location.longitude / 15) - equation;
    final sunriseDelta =
        _hourAngle(location.latitude, declination, 90 + _sunAltitude);
    final fajrDelta =
        _hourAngle(location.latitude, declination, 90 + _fajrAngle);
    final ishaDelta =
        _hourAngle(location.latitude, declination, 90 + _ishaAngle);
    final asrDelta = _asrHourAngle(location.latitude, declination);

    final prayerMoments = <PrayerMoment>[
      PrayerMoment(
        name: 'Subuh',
        time: _dateWithHourValue(date, dhuhrHour - fajrDelta),
        icon: Icons.wb_twilight_outlined,
      ),
      PrayerMoment(
        name: 'Zuhur',
        time: _dateWithHourValue(date, dhuhrHour),
        icon: Icons.light_mode_outlined,
      ),
      PrayerMoment(
        name: 'Asar',
        time: _dateWithHourValue(date, dhuhrHour + asrDelta),
        icon: Icons.sunny,
      ),
      PrayerMoment(
        name: 'Magrib',
        time: _dateWithHourValue(date, dhuhrHour + sunriseDelta),
        icon: Icons.wb_sunny_outlined,
      ),
      PrayerMoment(
        name: 'Isya',
        time: _dateWithHourValue(date, dhuhrHour + ishaDelta),
        icon: Icons.nightlight_round,
      ),
    ];

    PrayerMoment? activePrayer;
    for (final prayer in prayerMoments) {
      if (prayer.time.isAfter(locationNow)) {
        activePrayer = prayer;
        break;
      }
    }

    return prayerMoments
        .map(
          (prayer) => PrayerMoment(
            name: prayer.name,
            time: prayer.time,
            icon: prayer.icon,
            isActive: activePrayer?.name == prayer.name,
          ),
        )
        .toList();
  }

  static PrayerMoment _resolveNextPrayer(
      List<PrayerMoment> prayers, DateTime locationNow) {
    for (final prayer in prayers) {
      if (prayer.time.isAfter(locationNow)) {
        return prayer;
      }
    }

    final tomorrowSubuh = PrayerMoment(
      name: prayers.first.name,
      time: prayers.first.time.add(const Duration(days: 1)),
      icon: prayers.first.icon,
      isActive: true,
    );
    return tomorrowSubuh;
  }

  static int _dayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays + 1;
  }

  static double _solarDeclination(int dayOfYear) {
    final gamma = (2 * math.pi / 365) * (dayOfYear - 1);
    return 0.006918 -
        0.399912 * math.cos(gamma) +
        0.070257 * math.sin(gamma) -
        0.006758 * math.cos(2 * gamma) +
        0.000907 * math.sin(2 * gamma) -
        0.002697 * math.cos(3 * gamma) +
        0.00148 * math.sin(3 * gamma);
  }

  static double _equationOfTime(int dayOfYear) {
    final gamma = (2 * math.pi / 365) * (dayOfYear - 1);
    final minutes = 229.18 *
        (0.000075 +
            0.001868 * math.cos(gamma) -
            0.032077 * math.sin(gamma) -
            0.014615 * math.cos(2 * gamma) -
            0.040849 * math.sin(2 * gamma));
    return minutes / 60;
  }

  static double _hourAngle(
      double latitude, double declination, double zenithDegrees) {
    final latRad = _degToRad(latitude);
    final zenithRad = _degToRad(zenithDegrees);
    final cosValue =
        (math.cos(zenithRad) - math.sin(latRad) * math.sin(declination)) /
            (math.cos(latRad) * math.cos(declination));
    final clamped = cosValue.clamp(-1.0, 1.0);
    return _radToDeg(math.acos(clamped)) / 15;
  }

  static double _asrHourAngle(double latitude, double declination) {
    final latRad = _degToRad(latitude);
    final angle = -math.atan(1 / (1 + math.tan((latRad - declination).abs())));
    final cosValue =
        (math.sin(angle) - math.sin(latRad) * math.sin(declination)) /
            (math.cos(latRad) * math.cos(declination));
    final clamped = cosValue.clamp(-1.0, 1.0);
    return _radToDeg(math.acos(clamped)) / 15;
  }

  static DateTime _dateWithHourValue(DateTime date, double hourValue) {
    final totalSeconds = (hourValue * 3600).round();
    final normalizedSeconds = ((totalSeconds % 86400) + 86400) % 86400;
    return date.add(Duration(seconds: normalizedSeconds));
  }

  static double _calculateQiblaBearing(AppLocationData location) {
    final lat1 = _degToRad(location.latitude);
    final lng1 = _degToRad(location.longitude);
    final lat2 = _degToRad(_makkahLat);
    final lng2 = _degToRad(_makkahLng);
    final deltaLng = lng2 - lng1;

    final y = math.sin(deltaLng);
    final x =
        math.cos(lat1) * math.tan(lat2) - math.sin(lat1) * math.cos(deltaLng);
    final bearing = _radToDeg(math.atan2(y, x));
    return (bearing + 360) % 360;
  }

  static double _calculateDistanceToMakkah(AppLocationData location) {
    const earthRadiusKm = 6371.0;
    final lat1 = _degToRad(location.latitude);
    final lng1 = _degToRad(location.longitude);
    final lat2 = _degToRad(_makkahLat);
    final lng2 = _degToRad(_makkahLng);
    final deltaLat = lat2 - lat1;
    final deltaLng = lng2 - lng1;

    final a = math.pow(math.sin(deltaLat / 2), 2) +
        math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(deltaLng / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static String formatPrayerTime(DateTime value) {
    final hours = value.hour.toString().padLeft(2, '0');
    final minutes = value.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  static String formatCountdown(Duration value) {
    final totalSeconds = value.inSeconds.abs();
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  static String cardinalDirection(double bearing) {
    const labels = <String>[
      'N',
      'NE',
      'E',
      'SE',
      'S',
      'SW',
      'W',
      'NW',
    ];
    final index = ((bearing + 22.5) ~/ 45) % 8;
    return labels[index];
  }

  static double _degToRad(double value) => value * math.pi / 180;
  static double _radToDeg(double value) => value * 180 / math.pi;
}
