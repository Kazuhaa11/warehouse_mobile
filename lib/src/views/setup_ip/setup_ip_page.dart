import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_mobile/core/api/api_client.dart';

class SetupServerPage extends StatefulWidget {
  const SetupServerPage({super.key});

  @override
  State<SetupServerPage> createState() => _SetupServerPageState();
}

class _SetupServerPageState extends State<SetupServerPage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  Future<void> _saveServer() async {
    final ip = _controller.text.trim();

    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("IP Server tidak boleh kosong"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await ApiClient.instance.setServerIp(ip);

      if (mounted) context.go('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menyimpan IP server"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Konfigurasi Server"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Masukkan alamat server internal Anda:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _controller,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "IP Server",
                hintText: "Contoh: 10.8.15.33",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveServer,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Simpan & Lanjutkan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
