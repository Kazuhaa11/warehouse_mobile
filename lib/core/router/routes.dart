// import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../src/views/auth/pages/pages/login_page.dart';
// import '../../views/home/pages/home_page.dart';
import 'guard/auth_guard.dart';

abstract class AppPaths {
  static const login = '/login';
  static const home = '/home';
}

class AppRouter {
  AppRouter._();
  static final AppRouter instance = AppRouter._();

  late final GoRouter router = GoRouter(
    initialLocation: AppPaths.login,
    redirect: AuthGuard.redirect,
    routes: <RouteBase>[
      GoRoute(
        path: AppPaths.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      // GoRoute(
      //   path: AppPaths.home,
      //   name: 'home',
      //   // builder: (context, state) => const HomePage(),
      // ),
    ],
  );
}
