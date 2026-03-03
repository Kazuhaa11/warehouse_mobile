import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:warehouse_mobile/src/features/barang/data/barang_repository.dart';
import 'package:warehouse_mobile/src/features/peminjaman/cubit/peminjaman_cubit.dart';
import 'package:warehouse_mobile/common/widgets/app_button.dart';

class TambahBarangPage extends StatefulWidget {
  final int? barangId;
  final String? scan;

  const TambahBarangPage({super.key, this.barangId, this.scan});

  @override
  State<TambahBarangPage> createState() => _TambahBarangPageState();
}

class _TambahBarangPageState extends State<TambahBarangPage> {
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _picController = TextEditingController();
  final _bagianController = TextEditingController();
  final ValueNotifier<int> _qtyNotifier = ValueNotifier<int>(1);

  @override
  void dispose() {
    _picController.dispose();
    _bagianController.dispose();
    _qtyNotifier.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _loadBarang(BuildContext context) async {
    final repo = context.read<IBarangRepository>();

    if (widget.barangId != null) {
      return repo.getBarangDetail(widget.barangId!);
    } else if (widget.scan != null) {
      return repo.getBarangByMaterial(widget.scan!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Barang')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadBarang(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Barang tidak ditemukan'));
          }

          final barang = snapshot.data!;

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Barang',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),

                      Text('Nama: ${barang['material_description'] ?? '-'}'),
                      Text('Plant: ${barang['plant'] ?? '-'}'),
                      Text('Tanggal: $today'),

                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _picController,
                        decoration: const InputDecoration(
                          labelText: 'PIC',
                          hintText: 'Nama penanggung jawab',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'PIC wajib diisi'
                            : null,
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _bagianController,
                        decoration: const InputDecoration(
                          labelText: 'Bagian',
                          hintText: 'Contoh: Warehouse / Produksi',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Bagian wajib diisi'
                            : null,
                      ),

                      const Spacer(),

                      AppButton(
                        label: 'Tambah',
                        loading: _isLoading,
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() => _isLoading = true);

                          final payload = {
                            'tanggal': today,
                            'pic': _picController.text.trim(),
                            'sub_bagian': _bagianController.text.trim(),
                            'note': 'Peminjaman via mobile',
                            'items': [
                              {
                                if (widget.barangId != null)
                                  'barang_id': widget.barangId,
                                if (widget.scan != null) 'scan': widget.scan,
                                'qty': _qtyNotifier.value,
                                'plant': barang['plant'] ?? '1200',
                              },
                            ],
                          };

                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          final repo = context.read<PeminjamanCubit>().repo;

                          try {
                            final data = await repo.createPeminjaman(payload);

                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Peminjaman berhasil dibuat'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            navigator.pop(data);
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().contains('stok barang kosong')
                                      ? 'Stok barang kosong'
                                      : e.toString(),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                right: 16,
                bottom: 90,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: ValueListenableBuilder<int>(
                    valueListenable: _qtyNotifier,
                    builder: (_, qty, __) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (qty > 1) _qtyNotifier.value--;
                            },
                          ),
                          Text(
                            '$qty',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              _qtyNotifier.value++;
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
