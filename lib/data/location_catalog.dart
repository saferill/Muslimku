class AppLocationData {
  const AppLocationData({
    required this.label,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.utcOffsetHours,
  });

  final String label;
  final String country;
  final double latitude;
  final double longitude;
  final int utcOffsetHours;
}

const kKnownLocations = <AppLocationData>[
  AppLocationData(
    label: 'Jakarta, Indonesia',
    country: 'Indonesia',
    latitude: -6.2088,
    longitude: 106.8456,
    utcOffsetHours: 7,
  ),
  AppLocationData(
    label: 'Bandung, Indonesia',
    country: 'Indonesia',
    latitude: -6.9175,
    longitude: 107.6191,
    utcOffsetHours: 7,
  ),
  AppLocationData(
    label: 'Surabaya, Indonesia',
    country: 'Indonesia',
    latitude: -7.2575,
    longitude: 112.7521,
    utcOffsetHours: 7,
  ),
  AppLocationData(
    label: 'Yogyakarta, Indonesia',
    country: 'Indonesia',
    latitude: -7.7956,
    longitude: 110.3695,
    utcOffsetHours: 7,
  ),
  AppLocationData(
    label: 'Kuala Lumpur, Malaysia',
    country: 'Malaysia',
    latitude: 3.1390,
    longitude: 101.6869,
    utcOffsetHours: 8,
  ),
  AppLocationData(
    label: 'Makkah, Arab Saudi',
    country: 'Arab Saudi',
    latitude: 21.3891,
    longitude: 39.8579,
    utcOffsetHours: 3,
  ),
  AppLocationData(
    label: 'Dubai, Uni Emirat Arab',
    country: 'Uni Emirat Arab',
    latitude: 25.2048,
    longitude: 55.2708,
    utcOffsetHours: 4,
  ),
  AppLocationData(
    label: 'London, Britania Raya',
    country: 'Britania Raya',
    latitude: 51.5074,
    longitude: -0.1278,
    utcOffsetHours: 0,
  ),
];

AppLocationData lookupLocation(String label) {
  return kKnownLocations.firstWhere(
    (location) => location.label == label,
    orElse: () => kKnownLocations.first,
  );
}
