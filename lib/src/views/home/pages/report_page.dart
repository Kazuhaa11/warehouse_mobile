import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_mobile/common/widgets/custom_appbar.dart';
import 'package:warehouse_mobile/src/features/peminjaman/cubit/peminjaman_cubit.dart';
import 'package:warehouse_mobile/src/features/peminjaman/data/peminjaman_repository_impl.dart';
import 'package:warehouse_mobile/src/views/home/modals/peminjaman_detail_modal.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<PeminjamanCubit>();
      if (cubit.state is PeminjamanInitial) {
        cubit.loadList();
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: CustomAppBar(
        title: "Report",
        withSearch: true,
        searchHint: "Cari Barang Pinjaman",
        onSearch: (q) {
          if (q.isNotEmpty) {
            context.read<PeminjamanCubit>().loadList(q: q);
          } else {
            context.read<PeminjamanCubit>().loadList(); // reset → reload semua
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Barang Pinjaman",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<PeminjamanCubit, PeminjamanState>(
                builder: (context, state) {
                  if (state is PeminjamanLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is PeminjamanLoaded) {
                    if (state.list.isEmpty) {
                      return const Center(child: Text("Tidak ada data"));
                    }
                    return ListView.builder(
                      itemCount: state.list.length,
                      itemBuilder: (_, i) {
                        final row = state.list[i];
                        return Card(
                          child: ListTile(
                            title: Text(row['nomor'] ?? '-'),
                            subtitle: Text(
                              "Tanggal: ${row['tanggal']} | Status: ${row['status']}",
                            ),
                            onTap: () async {
                              final repo = PeminjamanRepositoryImpl();
                              final detail = await repo.getDetail(row['id']);
                              if (!context.mounted) return;
                              showDialog(
                                context: context,
                                builder: (_) => PeminjamanDetailModal(
                                  header: detail['header'],
                                  items: List<Map<String, dynamic>>.from(
                                    detail['items'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                  if (state is PeminjamanError) {
                    return Center(child: Text("Error: ${state.message}"));
                  }
                  return const Center(child: Text("Memuat data..."));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
