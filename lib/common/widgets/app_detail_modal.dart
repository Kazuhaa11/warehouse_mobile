import 'package:flutter/material.dart';

class AppDetailModal extends StatelessWidget {
  final String title;
  final List<Widget> headerContent;
  final List<Widget> itemList;

  const AppDetailModal({
    super.key,
    required this.title,
    required this.headerContent,
    required this.itemList,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...headerContent,
            const SizedBox(height: 16),
            const SizedBox(height: 8),
            Expanded(child: ListView(children: itemList)),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Tutup"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
