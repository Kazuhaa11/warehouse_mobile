import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse_mobile/core/storage/token_storage.dart';
import 'package:warehouse_mobile/src/features/stock_opname/cubit/stock_opname_cubit.dart';
import 'package:warehouse_mobile/src/views/add_barang/tambah_barang_page.dart';
import 'package:warehouse_mobile/src/views/admin/add_items/tambah_item_opname_page.dart';
import 'package:warehouse_mobile/src/views/admin/stock_opname_detail_page.dart';
import 'package:warehouse_mobile/src/views/admin/stock_opname_page.dart';
import 'package:warehouse_mobile/src/views/home/home_shell.dart';
import 'package:warehouse_mobile/src/views/setup_ip/setup_ip_page.dart';

import '../../src/views/auth/pages/pages/login_page.dart';
import '../../src/views/qr_page/qr_scanner_page.dart';
import 'guard/auth_guard.dart';

abstract class AppPaths {
  static const login = '/login';
  static const home = '/home';
  static const scan = '/scan';
  static const tambahBarang = '/tambah-barang';
  static const admin = '/admin';
  static const stockOpnameDetail = '/admin/stock-opname/:id';
  static const tambahItemOpname = '/admin/stock-opname/:id/tambah-item';
  static const setup = '/setup';
}

class AppRouter {
  AppRouter._();
  static final AppRouter instance = AppRouter._();

  late final GoRouter router = GoRouter(
    navigatorKey: TokenStorage.navigatorKey,
    initialLocation: AppPaths.setup,

    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final ip = prefs.getString('server_ip') ?? "";

      final isSetupPage = state.matchedLocation == AppPaths.setup;

      if (ip.isEmpty) {
        return isSetupPage ? null : AppPaths.setup;
      }

      return AuthGuard.redirectState(state);
    },

    routes: <RouteBase>[
      GoRoute(
        path: AppPaths.setup,
        name: 'setup',
        builder: (context, state) => const SetupServerPage(),
      ),

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
        builder: (context, state) =>
            QrScannerPage(onDetect: (code) => context.pop(code)),
      ),

      GoRoute(
        path: AppPaths.tambahBarang,
        name: 'tambah-barang',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final int? id = extra?['barang_id'] as int?;
          final String? scan = extra?['scan'] as String?;
          return TambahBarangPage(barangId: id, scan: scan);
        },
      ),

      GoRoute(
        path: AppPaths.admin,
        name: 'admin',
        builder: (context, state) => BlocProvider(
          create: (_) => StockOpnameCubit()..fetchSessions(),
          child: const StockOpnamePage(),
        ),
        routes: [
          GoRoute(
            path: 'stock-opname/:id',
            name: 'stock-opname-detail',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return StockOpnameDetailPage(sessionId: id);
            },
          ),
          GoRoute(
            path: 'stock-opname/:id/tambah-item',
            name: 'tambah-item-opname',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              final extra = state.extra as Map<String, dynamic>?;
              final scan = extra?['scan'] as String?;
              return TambahItemOpnamePage(sessionId: id, scan: scan ?? '');
            },
          ),
        ],
      ),
    ],
  );
}
