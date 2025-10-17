import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/stock_opname_detail/cubit/stock_opname_detail_cubit.dart';
import '../../views/qr_page/qr_scanner_page.dart';

class StockOpnameDetailPage extends StatelessWidget {
  final int sessionId;
  const StockOpnameDetailPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StockOpnameDetailCubit()..fetchDetail(sessionId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Items Stock Opname'),
          centerTitle: true,
        ),
        body: BlocConsumer<StockOpnameDetailCubit, StockOpnameDetailState>(
          listener: (context, state) {
            if (state is StockOpnameDetailFinalized) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is StockOpnameDetailError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is StockOpnameDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is StockOpnameDetailError) {
              return Center(child: Text(state.message));
            }

            if (state is StockOpnameDetailLoaded) {
              final sess = state.data['session'] ?? {};
              final items = List<Map<String, dynamic>>.from(
                state.data['items'] ?? [],
              );

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<StockOpnameDetailCubit>().fetchDetail(sessionId);
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sess['code'] ?? '-',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Jadwal: ${sess['scheduled_at'] ?? '-'}'),
                          Text('Finalized: ${sess['finalized_at'] ?? '-'}'),
                          const SizedBox(height: 8),
                          Text('Catatan: ${sess['note'] ?? '-'}'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final scanCode = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QrScannerPage(
                                    onDetect: (code) async {
                                      Navigator.pop(context, code);
                                    },
                                  ),
                                ),
                              );
                              if (scanCode != null &&
                                  scanCode.isNotEmpty &&
                                  context.mounted) {
                                final result = await context.pushNamed(
                                  'tambah-item-opname',
                                  pathParameters: {'id': sessionId.toString()},
                                  extra: {'scan': scanCode},
                                );
                                if (result == true && context.mounted) {
                                  context
                                      .read<StockOpnameDetailCubit>()
                                      .fetchDetail(sessionId);
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.qr_code_2,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Tambah Item',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await context
                                  .read<StockOpnameDetailCubit>()
                                  .finalizeSession(sessionId);
                              Future.delayed(const Duration(seconds: 1), () {
                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                }
                              });
                            },
                            icon: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Finalisasi',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'Daftar Item',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),

                    if (items.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Belum ada item.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: items.map((it) {
                          final diff = it['diff_qty'] ?? 0;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.inventory_2_outlined),
                              title: Text(it['material'] ?? '-'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stor. Loc: ${it['storage_location'] ?? '-'}',
                                  ),
                                  Text('Tercatat: ${it['counted_qty'] ?? 0}'),
                                ],
                              ),
                              trailing: Text(
                                'Δ $diff',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: diff == 0
                                      ? Colors.grey
                                      : Colors.redAccent,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              );
            }

            return const Center(child: Text('Tidak ada data.'));
          },
        ),
      ),
    );
  }
}
