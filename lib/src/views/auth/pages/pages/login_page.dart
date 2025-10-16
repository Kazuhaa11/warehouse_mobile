import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../common/widgets/app_button.dart';
import '../../../../../common/widgets/app_card.dart';
import '../../../../../common/widgets/app_text_field.dart';
import '../../../../../common/widgets/gaps.dart';
import '../../../../features/auth/cubit/login_cubit.dart';
import '../../../../../core/storage/token_storage.dart';
import '../../../../../core/router/guard/auth_guard.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailC = TextEditingController();
    final passC = TextEditingController();

    return BlocProvider(
      create: (_) => LoginCubit(),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AppCard(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Login',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      Gaps.h24,
                      AppTextField(
                        controller: emailC,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      Gaps.h16,
                      AppPasswordField(controller: passC, label: 'Password'),
                      Gaps.h24,

                      BlocConsumer<LoginCubit, LoginState>(
                        listener: (context, state) async {
                          state.whenOrNull(
                            success: (accessToken, user) async {
                              final role = (user['role'] ?? '')
                                  .toString()
                                  .toLowerCase();

                              await TokenStorage.instance.save(
                                access: accessToken,
                                refresh: '',
                                role: role,
                              );

                              if (!context.mounted) return;

                              if (role == 'admin') {
                                _showSnack(
                                  context,
                                  "Login sukses sebagai Admin",
                                  Colors.green,
                                );
                                context.go('/admin');
                              } else if (role == 'mobile') {
                                _showSnack(
                                  context,
                                  "Login sukses",
                                  Colors.green,
                                );
                                context.go('/home');
                              } else {
                                await TokenStorage.instance.clear();
                                AuthGuard.reset();
                                if (!context.mounted) return;

                                _showSnack(
                                  context,
                                  'Role "$role" tidak diizinkan untuk login.',
                                  Colors.red,
                                );
                              }
                            },
                            failure: (msg) {
                              _showSnack(context, msg, Colors.red);
                            },
                          );
                        },
                        builder: (context, state) {
                          final loading = state.maybeWhen(
                            loading: () => true,
                            orElse: () => false,
                          );

                          return AppButton(
                            label: 'Log In',
                            loading: loading,
                            onPressed: loading
                                ? null
                                : () {
                                    final email = emailC.text.trim();
                                    final pass = passC.text;

                                    if (email.isEmpty || pass.isEmpty) {
                                      _showSnack(
                                        context,
                                        "Email dan password wajib diisi.",
                                        Colors.orange,
                                      );
                                      return;
                                    }

                                    context.read<LoginCubit>().login(
                                      email,
                                      pass,
                                    );
                                  },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: color, content: Text(msg)));
  }
}
