import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_mobile/core/router/guard/auth_guard.dart';
import 'package:warehouse_mobile/src/features/auth/cubit/profile_cubit.dart';
import '../../features/stock_opname/cubit/stock_opname_cubit.dart';
import '../admin/stock_opname_detail_page.dart';

class StockOpnamePage extends StatelessWidget {
  const StockOpnamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Buat Sesi Stock Opname'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final profileCubit = context.read<ProfileCubit>();
              final profile = profileCubit.state;
              final userId = profile?['id'] ?? profile?['user_id'];

              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text('Apakah Anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      child: const Text('Batal'),
                      onPressed: () => Navigator.pop(dialogCtx, false),
                    ),
                    ElevatedButton(
                      child: const Text('Logout'),
                      onPressed: () => Navigator.pop(dialogCtx, true),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              await profileCubit.logout(userId);
              AuthGuard.reset();

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.go('/login');
                }
              });
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSessionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Buat Sesi'),
      ),
      body: BlocConsumer<StockOpnameCubit, StockOpnameState>(
        listener: (context, state) {
          if (state is StockOpnameError) {
            _showSnack(context, state.message, Colors.red);
          } else if (state is StockOpnameCreated) {
            _showSnack(context, state.message, Colors.green);
          }
        },
        builder: (context, state) {
          if (state is StockOpnameLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StockOpnameError) {
            return Center(child: Text(state.message));
          }

          if (state is StockOpnameLoaded) {
            var sessions = state.sessions;

            sessions.sort((a, b) {
              final aFinal = a['finalized_at'];
              final bFinal = b['finalized_at'];
              if (aFinal == null && bFinal != null) return -1;
              if (aFinal != null && bFinal == null) return 1;
              return 0;
            });

            if (sessions.isEmpty) {
              return const Center(child: Text('Belum ada sesi stock opname'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<StockOpnameCubit>().fetchSessions();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: sessions.length,
                itemBuilder: (_, i) {
                  final s = sessions[i];
                  final bool isFinalized = s['finalized_at'] != null;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(
                        s['code'] ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Catatan: ${s['note'] ?? '-'}'),
                          Text('Jadwal: ${s['scheduled_at'] ?? '-'}'),
                          Text(
                            'Finalisasi: ${s['finalized_at'] ?? '-'}',
                            style: TextStyle(
                              color: isFinalized
                                  ? Colors.green
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      trailing: isFinalized
                          ? const Chip(
                              avatar: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: Text(
                                'Finalized',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                            )
                          : ElevatedButton.icon(
                              icon: const Icon(
                                Icons.list_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Items',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              onPressed: () async {
                                final id =
                                    int.tryParse(s['id'].toString()) ?? 0;
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        StockOpnameDetailPage(sessionId: id),
                                  ),
                                );
                                if (result == true && context.mounted) {
                                  context
                                      .read<StockOpnameCubit>()
                                      .fetchSessions();
                                }
                              },
                            ),
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: Text('Tidak ada data.'));
        },
      ),
    );
  }

  void _showSnack(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context) {
    final noteController = TextEditingController();
    final parentContext = context;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (ctx) {
        DateTime? selectedDateTime;
        String formattedDate = "Pilih Jadwal Opname";

        return StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> handleSubmit() async {
              final note = noteController.text.trim();
              if (selectedDateTime == null) {
                _showSnack(
                  parentContext,
                  'Silakan pilih jadwal opname terlebih dahulu.',
                  Colors.orange,
                );
                return;
              }

              setState(() => isLoading = true);
              try {
                await parentContext.read<StockOpnameCubit>().createSession(
                  note,
                  selectedDateTime!.toIso8601String(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              } finally {
                if (ctx.mounted) setState(() => isLoading = false);
              }
            }

            return Stack(
              children: [
                AlertDialog(
                  title: const Text('Buat Sesi Stock Opname'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Catatan',
                          hintText: 'Catatan opsional',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                          );
                          if (date != null && ctx.mounted) {
                            final time = await showTimePicker(
                              context: ctx,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null && ctx.mounted) {
                              final combined = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                              setState(() {
                                selectedDateTime = combined;
                                formattedDate =
                                    "${combined.day}/${combined.month}/${combined.year} ${time.format(ctx)}";
                              });
                            }
                          }
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: Text(formattedDate),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: isLoading ? null : handleSubmit,
                      child: const Text('Buat Sesi'),
                    ),
                  ],
                ),
                if (isLoading)
                  Container(
                    color: const Color.fromRGBO(0, 0, 0, 0.4),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
