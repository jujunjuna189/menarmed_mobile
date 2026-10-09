import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:menarmed_mobile/widgets/paginated_report_list.dart';

class AbilityDataScreen extends StatefulWidget {
  const AbilityDataScreen({super.key});
  @override
  State<AbilityDataScreen> createState() => _AbilityDataScreenState();
}

class _AbilityDataScreenState extends State<AbilityDataScreen> {
  String _search = '';
  String _sort = 'latest';
  Timer? _debounce;
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _search = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Kemampuan'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Urutkan personil',
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (value) => setState(() => _sort = value),
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: 'latest',
                checked: _sort == 'latest',
                child: const Text('Terbaru'),
              ),
              CheckedPopupMenuItem(
                value: 'name_asc',
                checked: _sort == 'name_asc',
                child: const Text('Nama A–Z'),
              ),
              CheckedPopupMenuItem(
                value: 'name_desc',
                checked: _sort == 'name_desc',
                child: const Text('Nama Z–A'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              onChanged: onSearch,
              decoration: const InputDecoration(
                hintText: 'Cari personil',
                prefixIcon: Icon(Icons.search),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: PaginatedReportList(
              key: ValueKey((_search, _sort)),
              url: Api.penggunaShow,
              filters: {
                'role': jsonEncode([3]),
                'search': _search,
                'sort': _sort,
              },
              groupByMonth: false,
              itemBuilder: (context, value) => Column(
                children: [
                  ListTile(
                    tileColor: Colors.white,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF0F1F2),
                      child: Icon(
                        Icons.person_outline,
                        color: Color(0xFF383A3E),
                      ),
                    ),
                    title: Text(
                      value['name']?.toString() ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(value['pangkat']?.toString() ?? '-'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pushNamed(
                      '/ability',
                      arguments: jsonEncode({
                        'user_id': value['id'],
                        'name': value['name'],
                        'pangkat': value['pangkat'],
                      }),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
