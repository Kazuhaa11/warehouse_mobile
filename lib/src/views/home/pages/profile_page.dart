import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_mobile/common/widgets/app_card.dart';
import 'package:warehouse_mobile/common/widgets/custom_appbar.dart';
import '../../../../core/router/guard/auth_guard.dart';
import 'package:warehouse_mobile/src/features/auth/cubit/profile_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, Map<String, dynamic>?>(
      builder: (context, user) {
        if (user == null) {
          context
              .read<ProfileCubit>()
              .loadProfile();
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[300],
          appBar: const CustomAppBar(title: "Profile", withSearch: false),
          body: Center(
            child: AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 100,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Username: ${user['username'] ?? '-'}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Email: ${user['email'] ?? '-'}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Role: ${user['role'] ?? '-'}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final id = user['id'] as int?;
                      await context.read<ProfileCubit>().logout(id);
                      AuthGuard.reset();
                      if (context.mounted) context.go('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Logout"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
