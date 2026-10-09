import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:menarmed_mobile/widgets/paginated_report_list.dart';

class PositionScreen extends StatefulWidget {
  const PositionScreen({super.key});
  @override
  State<PositionScreen> createState() => _PositionScreenState();
}

class _PositionScreenState extends State<PositionScreen> {
  final _search = TextEditingController();
  int _category = 1;
  String _query = '';
  Timer? _debounce;

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Widget _categoryTab(String label, String asset) => Tab(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/position/$asset', width: 22, height: 22),
        const SizedBox(width: 8),
        Flexible(child: Text(label)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ColoredBox(
        color: const Color(0xFFF4F5F6),
        child: Column(
          children: [
            Material(
              color: Colors.white,
              child: TabBar(
                onTap: (index) => setState(() => _category = index + 1),
                indicatorWeight: 3,
                indicatorColor: const Color(0xFF252525),
                labelColor: const Color(0xFF252525),
                unselectedLabelColor: const Color(0xFF73777D),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                dividerColor: const Color(0xFFE2E4E7),
                tabs: [
                  _categoryTab('Kostrad', 'kostrad50.png'),
                  _categoryTab('Armed', 'armed50.png'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _search,
                onChanged: _onSearch,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Cari nama atau jabatan',
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: const TextStyle(color: Color(0xFF8A8F95)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 18),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 34,
                    minHeight: 34,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E4E7)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E4E7)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PaginatedReportList(
                key: ValueKey('$_category:$_query'),
                url: _category == 1 ? Api.kostradShow : Api.armedShow,
                groupByMonth: false,
                filters: {if (_query.isNotEmpty) 'search': _query},
                itemBuilder: (context, item) => Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pushNamed(
                      '/detail_kostrad',
                      arguments: jsonEncode({
                        ...item,
                        'title': _category == 1
                            ? 'Pejabat Kostrad'
                            : 'Pejabat Armed',
                      }),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE2E4E7)),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F2F3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              size: 21,
                              color: Color(0xFF555A60),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['jabatan']?.toString() ?? '-',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF73777D),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item['nama']?.toString() ?? '-',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF24272B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Color(0xFF8A8F95),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
