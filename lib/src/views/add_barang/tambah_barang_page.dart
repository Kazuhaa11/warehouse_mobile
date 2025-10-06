import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:warehouse_mobile/src/features/barang/data/barang_repository.dart';

class TambahBarangPage extends StatelessWidget {
  final int? barangId;
  final String? scan;

  const TambahBarangPage({super.key, this.barangId, this.scan});

  Future<Map<String, dynamic>?> _loadBarang(BuildContext context) async {
    final repo = context.read<IBarangRepository>();
    if (barangId != null) {
      return await repo.getBarangDetail(barangId!);
    } else if (scan != null) {
      return await repo.getBarangByMaterial(scan!);
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
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Barang", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Text("Nama: ${barang['material_description'] ?? '-'}"),
                Text("Tanggal: $today"),
                Text("Plant: ${barang['plant'] ?? '-'}"),
                const SizedBox(height: 16),

                // counter qty pakai ValueNotifier
                ValueListenableBuilder<int>(
                  valueListenable: qtyNotifier,
                  builder: (_, qty, __) {
                    return Row(
                      children: [
                        const Text("Jumlah: "),
                        IconButton(
                          onPressed: () {
                            if (qty > 1) qtyNotifier.value = qty - 1;
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        Text(
                          "$qty",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            qtyNotifier.value = qty + 1;
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    );
                  },
                ),

                const Spacer(),

                // tombol tambah
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context, {
                        if (barangId != null) "barang_id": barangId,
                        if (scan != null) "scan": scan,
                        "qty": qtyNotifier.value,
                      });
                    },
                    child: const Text("Tambah", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
