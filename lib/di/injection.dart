import 'package:flutter/widgets.dart';

import '../core/network/api_client.dart';
import '../core/services/audio_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/location_service.dart';
import '../core/services/notification_service.dart';
import '../core/storage/local_storage.dart';
import '../core/storage/secure_storage.dart';
import '../features/adzan/data/adzan_repository.dart';
import '../features/adzan/logic/adzan_controller.dart';
import '../features/audio/logic/audio_controller.dart';
import '../features/auth/data/auth_api.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/logic/auth_controller.dart';
import '../features/home/logic/home_controller.dart';
import '../features/notification/logic/notification_controller.dart';
import '../features/quran/data/quran_api.dart';
import '../features/quran/data/quran_repository.dart';
import '../features/quran/logic/quran_controller.dart';
import '../features/search/logic/search_controller.dart';
import '../features/settings/logic/security_controller.dart';
import '../features/settings/logic/settings_controller.dart';
import '../features/auth/logic/auth_state.dart';
import '../routes/app_navigator.dart';
import '../routes/route_names.dart';

class AppDependencies {
  AppDependencies({
    required this.authController,
    required this.homeController,
    required this.quranController,
    required this.adzanController,
    required this.audioController,
    required this.searchController,
    required this.notificationController,
    required this.securityController,
    required this.settingsController,
  });

  final AuthController authController;
  final HomeController homeController;
  final QuranController quranController;
  final AdzanController adzanController;
  final AudioController audioController;
  final SearchController searchController;
  final NotificationController notificationController;
  final SecurityController securityController;
  final SettingsController settingsController;

  void dispose() {
    authController.dispose();
    quranController.dispose();
    adzanController.dispose();
    audioController.dispose();
    searchController.dispose();
    notificationController.dispose();
    securityController.dispose();
  }
}

AppDependencies createDependencies() {
  final storage = LocalStorage();
  final secureStorage = SecureStorage();
  final apiClient = ApiClient();
  final authService = AuthService();
  final authRepository = AuthRepository(AuthApi(authService));
  final locationService = LocationService();
  final notificationService = NotificationService();
  final notificationController = NotificationController(storage);
  final audioService = AudioService();
  final connectivityService = ConnectivityService();
  final quranRepository = QuranRepository(
    api: QuranApi(apiClient),
    storage: storage,
  );
  final adzanRepository = const AdzanRepository();

  audioService.warmup();
  connectivityService.isOnline();
  notificationService.initialize(
    onTap: (payload) {
      notificationController.markReadByPayload(payload);
      final navigator = appNavigatorKey.currentState;
      if (navigator == null) return;
      if ((payload ?? '').startsWith('adzan:') ||
          (payload ?? '').startsWith('reminder:')) {
        navigator.pushNamed(RouteNames.adzanAlert, arguments: payload);
        return;
      }
      navigator.pushNamed(RouteNames.notifications);
    },
  );

  final authController = AuthController(
    storage: storage,
    repository: authRepository,
    locationService: locationService,
    notificationService: notificationService,
  );
  final quranController = QuranController(quranRepository);
  final adzanController = AdzanController(
    repository: adzanRepository,
    storage: storage,
    locationService: locationService,
    notificationService: notificationService,
    notificationController: notificationController,
  );
  final audioController = AudioController(
    service: audioService,
    notificationService: notificationService,
    quranController: quranController,
    storage: storage,
  );
  final searchController = SearchController(
    quranController: quranController,
    storage: storage,
  );
  final securityController = SecurityController(
    storage: storage,
    secureStorage: secureStorage,
  );
  notificationController.setDailyAyahEnabled(authController.state.dailyVerses);
  var previousAccessMode = authController.state.accessMode;

  authController.addListener(() {
    final location = authController.state.currentLocation;
    if (location != adzanController.locationLabel) {
      adzanController.syncLocation(location);
    }
    notificationController
        .setDailyAyahEnabled(authController.state.dailyVerses);
    if (authController.state.accessMode == AppAccessMode.authenticated &&
        previousAccessMode != AppAccessMode.authenticated) {
      quranController.syncCloudData();
    }
    previousAccessMode = authController.state.accessMode;
  });

  return AppDependencies(
    authController: authController,
    homeController: HomeController(adzanRepository),
    quranController: quranController,
    adzanController: adzanController,
    audioController: audioController,
    searchController: searchController,
    notificationController: notificationController,
    securityController: securityController,
    settingsController: SettingsController(
      authController: authController,
      storage: storage,
      quranController: quranController,
      audioController: audioController,
      searchController: searchController,
      notificationController: notificationController,
      adzanController: adzanController,
    ),
  );
}

class AppDependenciesScope extends InheritedWidget {
  const AppDependenciesScope({
    super.key,
    required this.dependencies,
    required super.child,
  });

  final AppDependencies dependencies;

  static AppDependencies of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppDependenciesScope>();
    assert(scope != null, 'AppDependenciesScope not found.');
    return scope!.dependencies;
  }

  @override
  bool updateShouldNotify(AppDependenciesScope oldWidget) {
    return oldWidget.dependencies != dependencies;
  }
}
