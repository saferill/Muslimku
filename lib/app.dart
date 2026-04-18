import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/dark_theme.dart';
import 'di/injection.dart';
import 'routes/app_navigator.dart';
import 'routes/app_routes.dart';
import 'routes/route_names.dart';
import 'shared/components/app_shell/app_lock_boundary.dart';

class MuslimkuApp extends StatefulWidget {
  const MuslimkuApp({super.key});

  @override
  State<MuslimkuApp> createState() => _MuslimkuAppState();
}

class _MuslimkuAppState extends State<MuslimkuApp>
    with WidgetsBindingObserver {
  late final AppDependencies _dependencies;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dependencies = createDependencies();
    _dependencies.authController.hydrate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dependencies.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _dependencies.authController.refreshSession();
    _dependencies.adzanController.scheduleUpcomingNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return AppDependenciesScope(
      dependencies: _dependencies,
      child: AnimatedBuilder(
        animation: _dependencies.authController,
        builder: (context, _) {
          final state = _dependencies.authController.state;
          final themeMode = switch (state.themeModeName) {
            'dark' => ThemeMode.dark,
            'light' => ThemeMode.light,
            _ => ThemeMode.system,
          };

          return MaterialApp(
            title: 'Muslimku',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.build(),
            darkTheme: DarkAppTheme.build(),
            themeMode: themeMode,
            navigatorKey: appNavigatorKey,
            builder: (context, child) {
              return AppLockBoundary(
                child: child ?? const SizedBox.shrink(),
              );
            },
            onGenerateRoute: AppRoutes.onGenerateRoute,
            initialRoute: RouteNames.bootstrap,
          );
        },
      ),
    );
  }
}
