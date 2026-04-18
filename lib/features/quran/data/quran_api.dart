import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class QuranApi {
  const QuranApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> fetchSurahList() {
    return _client.getJson('${ApiEndpoints.equranBaseUrl}${ApiEndpoints.surahList}');
  }

  Future<Map<String, dynamic>> fetchSurahDetail(int number) {
    return _client
        .getJson('${ApiEndpoints.equranBaseUrl}${ApiEndpoints.surahDetail(number)}');
  }

  Future<Map<String, dynamic>> fetchTafsir(int number) {
    return _client
        .getJson('${ApiEndpoints.equranBaseUrl}${ApiEndpoints.tafsir(number)}');
  }

  Future<Map<String, dynamic>> search({
    required String query,
    int limit = 10,
    List<String> types = const <String>['ayat', 'tafsir'],
    double minScore = 0.45,
  }) {
    return _client.postJson(
      '${ApiEndpoints.equranApiBaseUrl}${ApiEndpoints.vectorSearch}',
      body: <String, dynamic>{
        'cari': query,
        'batas': limit,
        'tipe': types,
        'skorMin': minScore,
      },
    );
  }
}
