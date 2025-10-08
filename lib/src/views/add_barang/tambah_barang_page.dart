import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:warehouse_mobile/src/features/barang/data/barang_repository.dart';
import 'package:warehouse_mobile/src/features/peminjaman/cubit/peminjaman_cubit.dart';
import 'package:warehouse_mobile/common/widgets/app_button.dart'; // ✅ gunakan AppButton custom

class TambahBarangPage extends StatefulWidget {
  final int? barangId;
  final String? scan;

  const TambahBarangPage({super.key, this.barangId, this.scan});

  @override
  State<TambahBarangPage> createState() => _TambahBarangPageState();
}

class _TambahBarangPageState extends State<TambahBarangPage> {
  bool _isLoading = false;

  Future<Map<String, dynamic>?> _loadBarang(BuildContext context) async {
    final repo = context.read<IBarangRepository>();
    if (widget.barangId != null) {
      return await repo.getBarangDetail(widget.barangId!);
    } else if (widget.scan != null) {
      return await repo.getBarangByMaterial(widget.scan!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final qtyNotifier = ValueNotifier<int>(1);

    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Barang")),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadBarang(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Barang tidak ditemukan"));
          }

          final barang = snapshot.data!;
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Barang",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text("Nama: ${barang['material_description'] ?? '-'}"),
                    Text("Tanggal: $today"),
                    Text("Plant: ${barang['plant'] ?? '-'}"),
                    const Spacer(),

                    AppButton(
                      label: "Tambah",
                      loading: _isLoading,
                      onPressed: () async {
                        setState(() => _isLoading = true);

                        final payload = {
                          "tanggal": today,
                          "note": "Peminjaman via mobile",
                          "items": [
                            {
                              if (widget.barangId != null)
                                "barang_id": widget.barangId,
                              if (widget.scan != null) "scan": widget.scan,
                              "qty": qtyNotifier.value,
                              "plant": barang['plant'] ?? '1200',
                            },
                          ],
                        };

                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        final cubit = context.read<PeminjamanCubit>();

                        try {
                          final data = await cubit.repo.createPeminjaman(
                            payload,
                          );

                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text("Peminjaman berhasil dibuat"),
                              backgroundColor: Colors.green,
                            ),
                          );

                          navigator.pop(data);
                        } catch (e) {
                          final msg = e.toString().contains('stok barang kosong') ? 'Stok Barang Kosong, tidak bisa dipinjam' : e.toString();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text("Gagal: $msg"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                    ),
                  ],
                ),
              ),

              Positioned(
                right: 16,
                bottom: 80,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 195, 195, 195),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ValueListenableBuilder<int>(
                    valueListenable: qtyNotifier,
                    builder: (_, qty, __) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.remove, size: 20),
                            onPressed: () {
                              if (qty > 1) qtyNotifier.value = qty - 1;
                            },
                          ),
                          Text(
                            "$qty",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: () {
                              qtyNotifier.value = qty + 1;
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
