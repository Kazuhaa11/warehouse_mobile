import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_mobile/common/widgets/custom_appbar.dart';
import 'package:warehouse_mobile/core/router/routes.dart';
import 'package:warehouse_mobile/src/features/barang/cubit/barang_cubit.dart';
import 'package:warehouse_mobile/src/features/barang/data/barang_repository.dart';
import 'package:warehouse_mobile/src/views/home/modals/barang_detail_modal.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: CustomAppBar(
        title: "Home",
        withSearch: true,
        searchHint: "Cari Barang",
        onSearch: (q) {
          if (q.isNotEmpty) {
            context.read<BarangCubit>().loadBarang(q: q);
          } else {
            context.read<BarangCubit>().reset();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push<String>(AppPaths.scan);

          if (result == null) return;
          if (!context.mounted) return;

          final id = int.tryParse(result);
          if (id != null) {
            final added = await context.push<Map<String, dynamic>>(
              '/tambah-barang',
              extra: {"barang_id": id},
            );
            if (added != null) {
            
            }
          } else {
            final added = await context.push<Map<String, dynamic>>(
              '/tambah-barang',
              extra: {"scan": result},
            );
            if (added != null){

            }
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "List Barang",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<BarangCubit, BarangState>(
                builder: (context, state) {
                  if (state is BarangLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is BarangLoaded) {
                    if (state.list.isEmpty) {
                      return const Center(child: Text("Tidak ada barang"));
                    }
                    return ListView.builder(
                      itemCount: state.list.length,
                      itemBuilder: (_, i) {
                        final b = state.list[i];
                        return Card(
                          child: ListTile(
                            title: Text(b['material_description'] ?? '-'),
                            subtitle: Text("Material: ${b['material']}"),
                            onTap: () async {
                              final repo = context.read<IBarangRepository>();
                              final detail = await repo.getBarangDetail(
                                b['id'],
                              );

                              if (!context.mounted) return;
                              showDialog(
                                context: context,
                                builder: (_) =>
                                    BarangDetailModal(barang: detail),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                  if (state is BarangError) {
                    return Center(child: Text("Error: ${state.message}"));
                  }
                  return const Center(child: Text("Cari barang untuk mulai"));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
