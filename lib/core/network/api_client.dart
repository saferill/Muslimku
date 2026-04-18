import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'network_exceptions.dart';

class ApiClient {
  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<Map<String, dynamic>> getJson(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response = await _request(
      () => _httpClient.get(Uri.parse(url), headers: headers),
    );
    final decoded = _decodeBody(response.bodyBytes);
    if (decoded is Map<String, dynamic>) return decoded;
    return Map<String, dynamic>.from(decoded as Map);
  }

  Future<List<dynamic>> getJsonList(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response = await _request(
      () => _httpClient.get(Uri.parse(url), headers: headers),
    );
    final decoded = _decodeBody(response.bodyBytes);
    return List<dynamic>.from(decoded as List);
  }

  Future<Map<String, dynamic>> postJson(
    String url, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    final mergedHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };
    final response = await _request(
      () => _httpClient.post(
        Uri.parse(url),
        headers: mergedHeaders,
        body: jsonEncode(body),
      ),
    );
    final decoded = _decodeBody(response.bodyBytes);
    if (decoded is Map<String, dynamic>) return decoded;
    return Map<String, dynamic>.from(decoded as Map);
  }

  Future<http.Response> _request(
    Future<http.Response> Function() action,
  ) async {
    try {
      final response = await action().timeout(const Duration(seconds: 20));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      throw NetworkException(
        'Permintaan gagal dengan status ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      throw const NetworkException('Permintaan melebihi batas waktu.');
    } on http.ClientException catch (error) {
      throw NetworkException(error.message);
    }
  }

  dynamic _decodeBody(List<int> bytes) {
    final body = utf8.decode(bytes);
    return jsonDecode(body);
  }
}
