import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatelessWidget {
  final Function(String material) onDetect;

  const QrScannerPage({super.key, required this.onDetect});

  @override
  Widget build(BuildContext context) {
    bool handled = false;
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: MobileScanner(
        onDetect: (capture) {
          if (handled) return;
          handled = true;

          final barcodes = capture.barcodes;
          final raw = barcodes.isNotEmpty ? barcodes.first.rawValue : null;

          if (raw == null || raw.isEmpty) {
            handled = false;
            return;
          }

          debugPrint('QR RAW: $raw');

          String? material;
          try {
            final decoded = jsonDecode(raw);
            if (decoded is Map<String, dynamic>) {
              material = decoded['material']?.toString();
            }
          } catch (_) {
            material = raw;
          }

          if (material == null || material.isEmpty) {
            handled = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('QR tidak valid'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          onDetect(material);
        },
      ),
    );
  }
}
