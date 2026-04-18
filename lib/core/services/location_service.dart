import 'package:geolocator/geolocator.dart';

import '../../features/adzan/data/models/prayer_time_model.dart';

class LocationLookupResult {
  const LocationLookupResult({
    required this.success,
    this.message,
    this.location,
    this.nearestLocation,
  });

  final bool success;
  final String? message;
  final PrayerLocationModel? location;
  final PrayerLocationModel? nearestLocation;
}

class LocationService {
  Future<LocationLookupResult> requestPermission() async {
    final permission = await _resolvePermission();
    if (permission == null) {
      return const LocationLookupResult(
        success: false,
        message: 'Izin lokasi belum diberikan.',
      );
    }
    return const LocationLookupResult(success: true);
  }

  Future<LocationLookupResult> detectNearestLocation() async {
    final detected = await detectCurrentLocation();
    if (!detected.success || detected.location == null) {
      return detected;
    }

    return LocationLookupResult(
      success: true,
      location: detected.location,
      nearestLocation: detected.nearestLocation,
      message: 'Lokasi berhasil diperbarui.',
    );
  }

  Future<LocationLookupResult> detectCurrentLocation() async {
    final permission = await _resolvePermission();
    if (permission == null) {
      return const LocationLookupResult(
        success: false,
        message: 'Izin lokasi belum diberikan.',
      );
    }

    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return const LocationLookupResult(
        success: false,
        message: 'Layanan lokasi perangkat sedang nonaktif.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final nearest = _nearestKnownLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      final offsetHours = DateTime.now().timeZoneOffset.inMinutes / 60.0;
      final exactLocation = PrayerLocationModel(
        label: nearest?.label ?? 'Lokasi Saat Ini',
        country: nearest?.country ?? 'GPS',
        latitude: position.latitude,
        longitude: position.longitude,
        utcOffsetHours: offsetHours,
        isExact: true,
      );

      return LocationLookupResult(
        success: true,
        location: exactLocation,
        nearestLocation: nearest,
        message: 'Lokasi GPS berhasil diperbarui.',
      );
    } catch (_) {
      return const LocationLookupResult(
        success: false,
        message: 'Tidak bisa mengambil lokasi saat ini.',
      );
    }
  }

  Future<LocationPermission?> _resolvePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    return permission;
  }

  PrayerLocationModel? _nearestKnownLocation({
    required double latitude,
    required double longitude,
  }) {
    PrayerLocationModel? nearest;
    double? nearestDistance;

    for (final location in PrayerLocationModel.knownLocations) {
      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        location.latitude,
        location.longitude,
      );
      if (nearestDistance == null || distance < nearestDistance) {
        nearestDistance = distance;
        nearest = location;
      }
    }
    return nearest;
  }
}
