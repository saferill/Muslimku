import 'package:geolocator/geolocator.dart';

import '../data/location_catalog.dart';

class LocationLookupResult {
  const LocationLookupResult({
    required this.success,
    this.message,
    this.location,
  });

  final bool success;
  final String? message;
  final AppLocationData? location;
}

class AppLocationService {
  static Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<LocationLookupResult> requestLocationPermission() async {
    final permission = await _resolvePermission();
    if (permission != null) {
      return const LocationLookupResult(success: true);
    }

    return const LocationLookupResult(
      success: false,
      message: 'Izin lokasi belum diberikan.',
    );
  }

  static Future<LocationLookupResult> detectNearestSupportedLocation() async {
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
      final nearest = _nearestSupportedLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return LocationLookupResult(
        success: true,
        location: nearest,
        message: 'Lokasi terdekat terdeteksi: ${nearest.label}.',
      );
    } catch (_) {
      return const LocationLookupResult(
        success: false,
        message: 'Tidak bisa mengambil lokasi saat ini. Coba lagi.',
      );
    }
  }

  static Future<LocationPermission?> _resolvePermission() async {
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

  static AppLocationData _nearestSupportedLocation({
    required double latitude,
    required double longitude,
  }) {
    AppLocationData? nearest;
    double? nearestDistance;

    for (final location in kKnownLocations) {
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

    return nearest ?? kKnownLocations.first;
  }
}
