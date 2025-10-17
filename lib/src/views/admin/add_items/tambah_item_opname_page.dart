import 'package:flutter/material.dart';
import 'package:warehouse_mobile/core/api/endpoints.dart';
import 'package:warehouse_mobile/core/api/api_client.dart';
import 'package:warehouse_mobile/common/widgets/app_button.dart';
import 'package:dio/dio.dart';

class TambahItemOpnamePage extends StatefulWidget {
  final int sessionId;
  final String scan;

  const TambahItemOpnamePage({
    super.key,
    required this.sessionId,
    required this.scan,
  });

  @override
  State<TambahItemOpnamePage> createState() => _TambahItemOpnamePageState();
}

class _TambahItemOpnamePageState extends State<TambahItemOpnamePage> {
  bool _isLoading = false;
  final qtyController = TextEditingController(text: "1");
  final Dio _dio = ApiClient.instance.dio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Item Opname")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Material: ${widget.scan}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Jumlah Terhitung",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            AppButton(
              label: "Tambah ke Opname",
              loading: _isLoading,
              onPressed: () async {
                setState(() => _isLoading = true);
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                final sessionId = widget.sessionId;
                final scan = widget.scan;
                final counted = int.tryParse(qtyController.text) ?? 0;

                try {
                  final payload = {"material": scan, "counted_qty": counted};

                  final res = await _dio.post(
                    Endpoints.stockOpnameItems(sessionId),
                    data: payload,
                  );
                  if (res.statusCode == 200 || res.statusCode == 201) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text("Item berhasil ditambahkan"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    if (mounted) navigator.pop(true);
                  } else {
                    throw Exception(
                      res.data['message'] ?? 'Gagal menambah item',
                    );
                  }
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text("Gagal menambah item: $e"),
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
    );
  }
}
