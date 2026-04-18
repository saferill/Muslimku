import 'package:geocoding/geocoding.dart' as geocoding;
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
      final resolvedPlacemark = await _placemarkForCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      final resolvedLabel = _labelFromPlacemark(
        placemark: resolvedPlacemark,
        fallback: nearest?.label ?? 'Lokasi Saat Ini',
      );
      final resolvedCountry =
          resolvedPlacemark?.country ?? nearest?.country ?? 'GPS';
      final exactLocation = PrayerLocationModel(
        label: resolvedLabel,
        country: resolvedCountry,
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

  Future<LocationLookupResult> resolveManualLocation(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return const LocationLookupResult(
        success: false,
        message: 'Masukkan nama kota, alamat, atau koordinat.',
      );
    }

    try {
      for (final known in PrayerLocationModel.knownLocations) {
        if (known.label.toLowerCase() == normalized.toLowerCase()) {
          return LocationLookupResult(
            success: true,
            location: PrayerLocationModel(
              label: known.label,
              country: known.country,
              latitude: known.latitude,
              longitude: known.longitude,
              utcOffsetHours: known.utcOffsetHours,
              isExact: true,
            ),
            nearestLocation: known,
            message: 'Lokasi manual berhasil diperbarui ke ${known.label}.',
          );
        }
      }

      final coordinates = _parseCoordinates(normalized);
      geocoding.Location location;
      if (coordinates != null) {
        location = geocoding.Location(
          latitude: coordinates.$1,
          longitude: coordinates.$2,
          timestamp: DateTime.now(),
        );
      } else {
        final results = await geocoding.locationFromAddress(normalized);
        if (results.isEmpty) {
          return const LocationLookupResult(
            success: false,
            message: 'Lokasi manual tidak ditemukan.',
          );
        }
        location = results.first;
      }

      final nearest = _nearestKnownLocation(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      final placemark = await _placemarkForCoordinates(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      final offsetHours =
          nearest?.utcOffsetHours ?? _approximateUtcOffset(location.longitude);
      final label = _labelFromPlacemark(
        placemark: placemark,
        fallback: normalized,
      );
      final prayerLocation = PrayerLocationModel(
        label: label,
        country: placemark?.country ?? nearest?.country ?? 'Manual',
        latitude: location.latitude,
        longitude: location.longitude,
        utcOffsetHours: offsetHours,
        isExact: true,
      );

      return LocationLookupResult(
        success: true,
        location: prayerLocation,
        nearestLocation: nearest,
        message: 'Lokasi manual berhasil diperbarui ke $label.',
      );
    } catch (_) {
      return const LocationLookupResult(
        success: false,
        message: 'Lokasi manual tidak bisa diproses sekarang.',
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

  Future<geocoding.Placemark?> _placemarkForCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isEmpty) return null;
      return placemarks.first;
    } catch (_) {
      return null;
    }
  }

  String _labelFromPlacemark({
    required geocoding.Placemark? placemark,
    required String fallback,
  }) {
    if (placemark == null) return fallback;
    final locality = <String?>[
      placemark.locality,
      placemark.subAdministrativeArea,
      placemark.administrativeArea,
    ].firstWhere(
      (value) => (value ?? '').trim().isNotEmpty,
      orElse: () => null,
    );
    final country = placemark.country;
    if ((locality ?? '').trim().isEmpty && (country ?? '').trim().isEmpty) {
      return fallback;
    }
    if ((country ?? '').trim().isEmpty) {
      return locality!;
    }
    if ((locality ?? '').trim().isEmpty) {
      return country!;
    }
    return '$locality, $country';
  }

  (double, double)? _parseCoordinates(String value) {
    final match = RegExp(
      r'^\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*$',
    ).firstMatch(value);
    if (match == null) return null;
    final latitude = double.tryParse(match.group(1) ?? '');
    final longitude = double.tryParse(match.group(2) ?? '');
    if (latitude == null || longitude == null) return null;
    return (latitude, longitude);
  }

  double _approximateUtcOffset(double longitude) {
    return (longitude / 15).roundToDouble().clamp(-12.0, 14.0);
  }
}
