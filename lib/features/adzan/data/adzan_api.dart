import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import 'models/prayer_time_model.dart';

class AdzanApi {
  const AdzanApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> fetchDailyTimings({
    required PrayerLocationModel location,
    required DateTime locationDate,
    required String calculationMethod,
    required String madhab,
  }) {
    final dateLabel =
        '${locationDate.day.toString().padLeft(2, '0')}-${locationDate.month.toString().padLeft(2, '0')}-${locationDate.year}';
    final uri =
        Uri.parse('${ApiEndpoints.aladhanBaseUrl}/timings/$dateLabel').replace(
      queryParameters: <String, String>{
        'latitude': location.latitude.toStringAsFixed(6),
        'longitude': location.longitude.toStringAsFixed(6),
        'method': '${_methodCode(calculationMethod)}',
        'school': '${_schoolCode(madhab)}',
      },
    );
    return _client.getJson(uri.toString());
  }

  int _methodCode(String method) {
    switch (method) {
      case 'Kementerian Agama RI':
        return 20;
      case 'Umm al-Qura':
        return 4;
      case 'Egyptian General Authority':
        return 5;
      case 'Muslim World League':
      default:
        return 3;
    }
  }

  int _schoolCode(String madhab) {
    switch (madhab) {
      case 'Hanafi':
        return 1;
      case 'Maliki':
      case 'Hanbali':
      case 'Shafi\'i':
      default:
        return 0;
    }
  }
}
