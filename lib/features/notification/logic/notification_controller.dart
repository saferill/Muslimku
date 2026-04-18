import 'package:flutter/foundation.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../routes/route_names.dart';
import '../data/models/notification_item_model.dart';

class NotificationController extends ChangeNotifier {
  NotificationController(this._storage) {
    _hydrate();
  }

  static const _storageKey = 'notifications.center.v1';

  final LocalStorage _storage;

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
        .toList();
    _seedDefaults();
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
      _seedDefaults();
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
    _seedDefaults();
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
    _seedDefaults();
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

  void _seedDefaults() {
    final updateId = 'seed_app_update';
    final hasUpdate = _items.any((item) => item.id == updateId);
    if (!hasUpdate) {
      _items = <NotificationItemModel>[
        NotificationItemModel(
          id: updateId,
          title: 'App Update: Qibla Compass',
          body:
              'Qibla compass and prayer sync are active. Pastikan izin lokasi tetap aktif untuk hasil terbaik.',
          category: 'update',
          createdAtEpochMs: DateTime.now().millisecondsSinceEpoch,
          read: false,
          routeName: RouteNames.about,
        ),
        ..._items,
      ];
    }

    if (_dailyAyahEnabled) {
      final dailyId =
          'daily_ayah_${DateTime.now().year}_${DateTime.now().month}_${DateTime.now().day}';
      final hasDailyAyah = _items.any((item) => item.id == dailyId);
      if (!hasDailyAyah) {
        _items = <NotificationItemModel>[
          NotificationItemModel(
            id: dailyId,
            title: 'Daily Ayah Reflection',
            body:
                '"So remember Me; I will remember you..." (2:152) • Tap untuk lanjut baca di reader.',
            category: 'daily_ayah',
            createdAtEpochMs: DateTime.now().millisecondsSinceEpoch,
            read: false,
            routeName: RouteNames.reader,
            routeIntArgument: 2,
          ),
          ..._items,
        ];
      }
    }
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
    return _storage.setJsonList(
      _storageKey,
      _items.map((item) => item.toJson()).toList(),
    );
  }
}

