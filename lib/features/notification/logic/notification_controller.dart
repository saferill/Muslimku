import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../routes/route_names.dart';
import '../data/models/notification_item_model.dart';

class NotificationController extends ChangeNotifier {
  NotificationController(
    this._storage, {
    FirebaseFirestore? firestore,
    required String? Function() currentUserIdProvider,
    required bool Function() isAuthenticatedProvider,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _currentUserIdProvider = currentUserIdProvider,
        _isAuthenticatedProvider = isAuthenticatedProvider {
    _hydrate();
  }

  static const _storageKey = 'notifications.center.v1';

  final LocalStorage _storage;
  final FirebaseFirestore _firestore;
  final String? Function() _currentUserIdProvider;
  final bool Function() _isAuthenticatedProvider;

  bool _loading = true;
  bool _dailyAyahEnabled = true;
  List<NotificationItemModel> _items = const <NotificationItemModel>[];

  bool get loading => _loading;
  List<NotificationItemModel> get items =>
      List<NotificationItemModel>.unmodifiable(_items);
  bool get hasUnread => _items.any((item) => !item.read);

  Future<void> _hydrate() async {
    await _storage.init();
    _items = _storage
        .getJsonList(_storageKey)
        .map(NotificationItemModel.fromJson)
        .where(
            (item) => item.id != 'seed_app_update' && item.category != 'update')
        .toList();
    await _hydrateCloudItems();
    _ensureTodayDailyAyah();
    _sort();
    _loading = false;
    await _persist();
    notifyListeners();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    await _hydrate();
  }

  Future<void> setDailyAyahEnabled(bool value) async {
    _dailyAyahEnabled = value;
    if (!value) {
      _items = _items.where((item) => item.category != 'daily_ayah').toList();
    } else {
      _ensureTodayDailyAyah();
    }
    _sort();
    await _persist();
    notifyListeners();
  }

  Future<void> syncScheduledNotifications(
    List<ScheduledNotificationInput> items,
  ) async {
    await _storage.init();
    final preserved = _items
        .where(
          (item) => item.category != 'adzan' && item.category != 'reminder',
        )
        .toList();

    final scheduledItems = items.map((item) {
      final category =
          (item.payload ?? '').startsWith('reminder:') ? 'reminder' : 'adzan';
      return NotificationItemModel(
        id: 'scheduled_${item.id}',
        title: item.title,
        body: item.body,
        category: category,
        createdAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        scheduledAtEpochMs: item.when.millisecondsSinceEpoch,
        payload: item.payload,
        routeName: category == 'reminder' || category == 'adzan'
            ? RouteNames.adzanAlert
            : RouteNames.notifications,
        routeStringArgument: item.payload,
        read: false,
      );
    }).toList();

    _items = <NotificationItemModel>[
      ...preserved,
      ...scheduledItems,
    ];
    _ensureTodayDailyAyah();
    _sort();
    await _persist();
    notifyListeners();
  }

  Future<void> recordInstantNotification({
    required String id,
    required String title,
    required String body,
    required String category,
    String? payload,
    String? routeName,
    int? routeIntArgument,
    String? routeStringArgument,
  }) async {
    await _storage.init();
    _items = <NotificationItemModel>[
      NotificationItemModel(
        id: id,
        title: title,
        body: body,
        category: category,
        createdAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        read: false,
        payload: payload,
        routeName: routeName,
        routeIntArgument: routeIntArgument,
        routeStringArgument: routeStringArgument,
      ),
      ..._items.where((item) => item.id != id),
    ];
    _sort();
    await _persist();
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    _items = _items
        .map((item) => item.id == id ? item.copyWith(read: true) : item)
        .toList();
    await _persist();
    notifyListeners();
  }

  Future<void> markReadByPayload(String? payload) async {
    if ((payload ?? '').isEmpty) return;
    _items = _items
        .map((item) =>
            item.payload == payload ? item.copyWith(read: true) : item)
        .toList();
    await _persist();
    notifyListeners();
  }

  Future<void> markAllRead() async {
    _items = _items.map((item) => item.copyWith(read: true)).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _items = const <NotificationItemModel>[];
    _ensureTodayDailyAyah();
    await _persist();
    notifyListeners();
  }

  Object? routeArgumentFor(NotificationItemModel item) {
    if (item.routeStringArgument != null &&
        item.routeStringArgument!.isNotEmpty) {
      return item.routeStringArgument;
    }
    return item.routeIntArgument;
  }

  void _ensureTodayDailyAyah() {
    if (!_dailyAyahEnabled) return;
    final now = DateTime.now();
    final dailyId = 'daily_ayah_${now.year}_${now.month}_${now.day}';
    final hasDailyAyah = _items.any((item) => item.id == dailyId);
    if (hasDailyAyah) return;

    _items = <NotificationItemModel>[
      NotificationItemModel(
        id: dailyId,
        title: 'Refleksi Ayat Harian',
        body:
            '${AppConstants.dailyAyah} • Ketuk untuk melanjutkan bacaan di reader.',
        category: 'daily_ayah',
        createdAtEpochMs: now.millisecondsSinceEpoch,
        read: false,
        routeName: RouteNames.reader,
        routeIntArgument: 2,
      ),
      ..._items,
    ];
  }

  void _sort() {
    _items = List<NotificationItemModel>.from(_items)
      ..sort((a, b) {
        final aTime = a.scheduledAtEpochMs ?? a.createdAtEpochMs;
        final bTime = b.scheduledAtEpochMs ?? b.createdAtEpochMs;
        return bTime.compareTo(aTime);
      });
  }

  Future<void> _persist() {
    return _storage
        .setJsonList(
          _storageKey,
          _items.map((item) => item.toJson()).toList(),
        )
        .then((_) => _syncCloudIfNeeded());
  }

  Future<void> _hydrateCloudItems() async {
    final uid = _currentUserIdProvider();
    if (!_isAuthenticatedProvider() || (uid ?? '').isEmpty) {
      return;
    }

    try {
      final snapshot = await _cloudDoc(uid!).get();
      final rawItems = snapshot.data()?['items'];
      if (rawItems is! List) return;

      final merged = <String, NotificationItemModel>{
        for (final item in _items) item.id: item,
      };
      for (final entry in rawItems) {
        if (entry is! Map) continue;
        final item = NotificationItemModel.fromJson(
          Map<String, dynamic>.from(entry),
        );
        final current = merged[item.id];
        if (current == null ||
            item.createdAtEpochMs >= current.createdAtEpochMs) {
          merged[item.id] = item;
        }
      }
      _items = merged.values.toList();
    } catch (_) {
      // Keep local inbox when cloud fetch fails.
    }
  }

  Future<void> _syncCloudIfNeeded() async {
    final uid = _currentUserIdProvider();
    if (!_isAuthenticatedProvider() || (uid ?? '').isEmpty) {
      return;
    }

    try {
      await _cloudDoc(uid!).set(
        <String, dynamic>{
          'items': _items.map((item) => item.toJson()).toList(),
          'updatedAtEpochMs': DateTime.now().millisecondsSinceEpoch,
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // Keep local state authoritative if cloud sync fails.
    }
  }

  DocumentReference<Map<String, dynamic>> _cloudDoc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('state')
        .doc('notification_center');
  }
}
