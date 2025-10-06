import 'package:flutter/material.dart';
import '../../../../common/widgets/app_detail_modal.dart';

class BarangDetailModal extends StatelessWidget {
  final Map<String, dynamic> barang;

  const BarangDetailModal({super.key, required this.barang});

  @override
  Widget build(BuildContext context) {
    return AppDetailModal(
      title: "Detail Barang",
      headerContent: [
        Text("Material        : ${barang['material'] ?? '-'}"),
        Text("Deskripsi       : ${barang['material_description'] ?? '-'}"),
        Text("UOM             : ${barang['base_unit_of_measure'] ?? '-'}"),
        Text("Plant           : ${barang['plant'] ?? '-'}"),
        Text("Material Type   : ${barang['material_type'] ?? '-'}"),
        Text("Material Group  : ${barang['material_group'] ?? '-'}"),
        Text("Storage ID      : ${barang['storage_id']?.toString() ?? '-'}"),
        Text("Storage Loc     : ${barang['storage_location'] ?? '-'}"),
        const Divider(),
        Text("Storage Name    : ${barang['storage_name'] ?? '-'}"),
        Text("Zone            : ${barang['zone'] ?? '-'}"),
        Text("Rack            : ${barang['rack'] ?? '-'}"),
        Text("Bin             : ${barang['bin'] ?? '-'}"),
        Text("Path            : ${barang['path'] ?? '-'}"),
      ],
      itemList: const [],
    );
  }
}
