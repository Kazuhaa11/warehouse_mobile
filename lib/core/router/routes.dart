// import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_mobile/src/views/add_barang/tambah_barang_page.dart';
import 'package:warehouse_mobile/src/views/home/home_shell.dart';
import '../../src/views/auth/pages/pages/login_page.dart';
import '../../src/views/qr_page/qr_scanner_page.dart';
import 'guard/auth_guard.dart';

abstract class AppPaths {
  static const login = '/login';
  static const home = '/home';
  static const scan = '/scan';
  static const tambahBarang = '/tambah-barang';
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
      GoRoute(
        path: AppPaths.home,
        name: 'home',
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: AppPaths.scan,
        name: 'scan',
        builder: (context, state) {
          return QrScannerPage(
            onDetect: (code) {
              context.pop(code);
            },
          );
        },
      ),
      GoRoute(
        path: AppPaths.tambahBarang,
        name: 'tambah-barang',
        builder: (context, state) {
          final id = state.extra as int;
          return TambahBarangPage(barangId: id);
        },
      ),
    ],
  );
}
