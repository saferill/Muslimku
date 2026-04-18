import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  String? getString(String key) => _prefs?.getString(key);
  bool? getBool(String key) => _prefs?.getBool(key);
  int? getInt(String key) => _prefs?.getInt(key);
  double? getDouble(String key) => _prefs?.getDouble(key);
  List<String>? getStringList(String key) => _prefs?.getStringList(key);
  Set<String> getKeys() => _prefs?.getKeys() ?? <String>{};

  Object? getValue(String key) => _prefs?.get(key);

  Map<String, dynamic>? getJsonMap(String key) {
    final raw = getString(key);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic>
        ? decoded
        : Map<String, dynamic>.from(decoded as Map);
  }

  List<Map<String, dynamic>> getJsonList(String key) {
    final raw = getString(key);
    if (raw == null || raw.isEmpty) return const <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const <Map<String, dynamic>>[];
    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  Future<void> setJsonMap(String key, Map<String, dynamic> value) async {
    await setString(key, jsonEncode(value));
  }

  Future<void> setJsonList(String key, List<Map<String, dynamic>> value) async {
    await setString(key, jsonEncode(value));
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }

  Map<String, dynamic> dumpAll() {
    final prefs = _prefs;
    if (prefs == null) return <String, dynamic>{};
    return <String, dynamic>{
      for (final key in prefs.getKeys()) key: prefs.get(key),
    };
  }

  Future<void> importDump(
    Map<String, dynamic> data, {
    bool clearExisting = false,
  }) async {
    await init();
    if (clearExisting) {
      await clear();
    }

    for (final entry in data.entries) {
      final value = entry.value;
      if (value is String) {
        await setString(entry.key, value);
      } else if (value is bool) {
        await setBool(entry.key, value);
      } else if (value is int) {
        await setInt(entry.key, value);
      } else if (value is double) {
        await setDouble(entry.key, value);
      } else if (value is List) {
        await setStringList(
          entry.key,
          value.map((item) => '$item').toList(),
        );
      } else if (value != null) {
        await setString(entry.key, jsonEncode(value));
      }
    }
  }
}
