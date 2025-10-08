import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatelessWidget {
  final Function(String code) onDetect;
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

          if (raw != null) {
            debugPrint("QR DETECTED: $raw");
            onDetect(raw);
          }
        },
      ),
    );
  }
}
