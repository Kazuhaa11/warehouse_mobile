import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_mobile/core/router/routes.dart';

// auth
import 'package:warehouse_mobile/src/features/auth/cubit/login_cubit.dart';
import 'package:warehouse_mobile/src/features/auth/cubit/profile_cubit.dart';
import 'package:warehouse_mobile/src/features/auth/data/auth_repository_impl.dart';

// barang
import 'package:warehouse_mobile/src/features/barang/cubit/barang_cubit.dart';
import 'package:warehouse_mobile/src/features/barang/data/barang_repository_impl.dart';
import 'package:warehouse_mobile/src/features/barang/data/barang_repository.dart';

// peminjaman
import 'package:warehouse_mobile/src/features/peminjaman/cubit/peminjaman_cubit.dart';
import 'package:warehouse_mobile/src/features/peminjaman/data/peminjaman_repository_impl.dart';

class WarehouseApp extends StatelessWidget {
  const WarehouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepositoryImpl>(
          create: (_) => AuthRepositoryImpl(),
        ),
        RepositoryProvider<IBarangRepository>(
          create: (_) => BarangRepositoryImpl(),
        ),
        RepositoryProvider<PeminjamanRepositoryImpl>(
          create: (_) => PeminjamanRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LoginCubit()),
          BlocProvider(
            create: (ctx) => ProfileCubit(ctx.read<AuthRepositoryImpl>()),
          ),
          BlocProvider(
            create: (ctx) => BarangCubit(ctx.read<IBarangRepository>()),
          ),
          BlocProvider(
            create: (ctx) =>
                PeminjamanCubit(ctx.read<PeminjamanRepositoryImpl>()),
          ),
        ],
        child: MaterialApp.router(
          title: 'Warehouse Mobile',
          theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
          routerConfig: AppRouter.instance.router,
        ),
      ),
    );
  }
}
