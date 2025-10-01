import 'package:flutter/material.dart';
import '../core/router/routes.dart';

class WarehouseApp extends StatelessWidget {
  const WarehouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.instance.router;
    return MaterialApp.router(
      title: 'Warehouse Mobile',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1F6FEB),
        scaffoldBackgroundColor: const Color(0xFF1F6FEB),
        fontFamily: 'Poppins',
      ),
    );
  }
}
