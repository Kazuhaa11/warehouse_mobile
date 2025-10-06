import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool withSearch;
  final String searchHint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSearch;

  const CustomAppBar({
    super.key,
    required this.title,
    this.withSearch = false,
    this.searchHint = "Cari Barang",
    this.onChanged,
    this.onSearch,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize =>
      withSearch ? const Size.fromHeight(120) : const Size.fromHeight(70);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.withSearch) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (q) {
                      if (widget.onSearch != null) {
                        widget.onSearch!(q.trim());
                      }
                    },
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    final q = _searchController.text.trim();
                    if (widget.onSearch != null) {
                      widget.onSearch!(q);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.search, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
