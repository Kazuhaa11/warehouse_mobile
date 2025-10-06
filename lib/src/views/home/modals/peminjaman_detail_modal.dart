import 'package:flutter/material.dart';
import '../../../../common/widgets/app_detail_modal.dart';

class PeminjamanDetailModal extends StatelessWidget {
  final Map<String, dynamic> header;
  final List<Map<String, dynamic>> items;

  const PeminjamanDetailModal({
    super.key,
    required this.header,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return AppDetailModal(
      title: "Detail Peminjaman",
      headerContent: [
        Text("No Nota : ${header['nomor'] ?? '-'}"),
        Text("Tanggal : ${header['tanggal'] ?? '-'}"),
        Text("Status  : ${header['status'] ?? '-'}"),
        Text("Peminjam: ${header['peminjam_username'] ?? '-'}"),
        const Divider(),
      ],
      itemList: items.map((it) {
        return Card(
          child: ListTile(
            title: Text(it['material'] ?? '-'),
            subtitle: Text("Qty: ${it['qty']} ${it['uom'] ?? ''}"),
            trailing: Text(it['storage_location'] ?? ''),
          ),
        );
      }).toList(),
    );
  }
}
