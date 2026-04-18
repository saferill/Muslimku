import 'dart:math' as math;

import 'package:flutter/material.dart';

class PrayerLocationModel {
  const PrayerLocationModel({
    required this.label,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.utcOffsetHours,
    this.isExact = false,
  });

  final String label;
  final String country;
  final double latitude;
  final double longitude;
  final double utcOffsetHours;
  final bool isExact;

  static const knownLocations = <PrayerLocationModel>[
    PrayerLocationModel(
      label: 'Jakarta, Indonesia',
      country: 'Indonesia',
      latitude: -6.2088,
      longitude: 106.8456,
      utcOffsetHours: 7.0,
    ),
    PrayerLocationModel(
      label: 'Bandung, Indonesia',
      country: 'Indonesia',
      latitude: -6.9175,
      longitude: 107.6191,
      utcOffsetHours: 7.0,
    ),
    PrayerLocationModel(
      label: 'Surabaya, Indonesia',
      country: 'Indonesia',
      latitude: -7.2575,
      longitude: 112.7521,
      utcOffsetHours: 7.0,
    ),
    PrayerLocationModel(
      label: 'Semarang, Indonesia',
      country: 'Indonesia',
      latitude: -6.9667,
      longitude: 110.4167,
      utcOffsetHours: 7.0,
    ),
    PrayerLocationModel(
      label: 'Yogyakarta, Indonesia',
      country: 'Indonesia',
      latitude: -7.7956,
      longitude: 110.3695,
      utcOffsetHours: 7.0,
    ),
    PrayerLocationModel(
      label: 'Medan, Indonesia',
      country: 'Indonesia',
      latitude: 3.5952,
      longitude: 98.6722,
      utcOffsetHours: 7.0,
    ),
    PrayerLocationModel(
      label: 'Palembang, Indonesia',
      country: 'Indonesia',
      latitude: -2.9761,
      longitude: 104.7754,
      utcOffsetHours: 7.0,
    ),
    PrayerLocationModel(
      label: 'Makassar, Indonesia',
      country: 'Indonesia',
      latitude: -5.1477,
      longitude: 119.4327,
      utcOffsetHours: 8.0,
    ),
    PrayerLocationModel(
      label: 'Denpasar, Indonesia',
      country: 'Indonesia',
      latitude: -8.6705,
      longitude: 115.2126,
      utcOffsetHours: 8.0,
    ),
    PrayerLocationModel(
      label: 'Balikpapan, Indonesia',
      country: 'Indonesia',
      latitude: -1.2379,
      longitude: 116.8529,
      utcOffsetHours: 8.0,
    ),
    PrayerLocationModel(
      label: 'Banjarmasin, Indonesia',
      country: 'Indonesia',
      latitude: -3.3186,
      longitude: 114.5944,
      utcOffsetHours: 8.0,
    ),
    PrayerLocationModel(
      label: 'Banda Aceh, Indonesia',
      country: 'Indonesia',
      latitude: 5.5483,
      longitude: 95.3238,
      utcOffsetHours: 7.0,
    ),
    PrayerLocationModel(
      label: 'Kuala Lumpur, Malaysia',
      country: 'Malaysia',
      latitude: 3.1390,
      longitude: 101.6869,
      utcOffsetHours: 8.0,
    ),
    PrayerLocationModel(
      label: 'Makkah, Arab Saudi',
      country: 'Arab Saudi',
      latitude: 21.3891,
      longitude: 39.8579,
      utcOffsetHours: 3.0,
    ),
  ];

  static PrayerLocationModel byLabel(String label) {
    return knownLocations.firstWhere(
      (location) => location.label == label,
      orElse: () => knownLocations.first,
    );
  }
}

class PrayerTimeModel {
  const PrayerTimeModel({
    required this.name,
    required this.time,
    required this.icon,
    required this.isActive,
  });

  final String name;
  final DateTime time;
  final IconData icon;
  final bool isActive;

  String get formatted {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class PrayerSnapshotModel {
  const PrayerSnapshotModel({
    required this.location,
    required this.locationNow,
    required this.prayers,
    required this.nextPrayer,
    required this.remaining,
    required this.qiblaBearing,
    required this.distanceToMakkahKm,
  });

  final PrayerLocationModel location;
  final DateTime locationNow;
  final List<PrayerTimeModel> prayers;
  final PrayerTimeModel nextPrayer;
  final Duration remaining;
  final double qiblaBearing;
  final double distanceToMakkahKm;

  static double degToRad(double value) => value * math.pi / 180;
  static double radToDeg(double value) => value * 180 / math.pi;
}
