import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatelessWidget {
  final Function(String code) onDetect;
  const QrScannerPage({super.key, required this.onDetect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final raw = barcodes.first.rawValue;
            print("Qr detected: $raw");
            if (raw != null) {
              Navigator.pop(context);
              onDetect(raw);
            }
          }
        },
      ),
    );
  }
}
