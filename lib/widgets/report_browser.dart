import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menarmed_mobile/widgets/paginated_report_list.dart';

class ReportBrowser extends StatefulWidget {
  const ReportBrowser({
    super.key,
    required this.url,
    required this.itemBuilder,
  });
  final String url;
  final Widget Function(BuildContext, Map<String, dynamic>) itemBuilder;

  @override
  State<ReportBrowser> createState() => _ReportBrowserState();
}

class _ReportBrowserState extends State<ReportBrowser> {
  final _search = TextEditingController();
  DateTimeRange? _dates;
  Map<String, String> _filters = {};
  int _revision = 0;

  void _apply() {
    setState(() {
      _filters = {
        if (_search.text.trim().isNotEmpty) 'search': _search.text.trim(),
        if (_dates != null)
          'date_from': DateFormat('yyyy-MM-dd').format(_dates!.start),
        if (_dates != null)
          'date_to': DateFormat('yyyy-MM-dd').format(_dates!.end),
      };
      _revision++;
    });
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final dates = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: _dates,
    );
    if (!mounted || dates == null) return;
    _dates = dates;
    _apply();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF4F5F6),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    style: const TextStyle(fontSize: 13),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _apply(),
                    decoration: InputDecoration(
                      hintText: 'Cari nama',
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 34,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E4E7)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E4E7)),
                      ),
                      suffixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 34,
                          height: 34,
                        ),
                        visualDensity: VisualDensity.compact,
                        iconSize: 18,
                        onPressed: _apply,
                        tooltip: 'Cari',
                        icon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: _pickDates,
                    tooltip: 'Rentang tanggal',
                    constraints: const BoxConstraints(
                      minWidth: 34,
                      minHeight: 34,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    iconSize: 18,
                    icon: Icon(Icons.date_range, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (_filters.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (_filters.containsKey('search'))
                      InputChip(
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        labelStyle: const TextStyle(fontSize: 11),
                        label: Text(_filters['search']!),
                        avatar: const Icon(Icons.search, size: 16),
                        onDeleted: () {
                          _search.clear();
                          _apply();
                        },
                      ),
                    if (_dates != null)
                      InputChip(
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        labelStyle: const TextStyle(fontSize: 11),
                        label: Text(
                          '${DateFormat('dd MMM').format(_dates!.start)} - ${DateFormat('dd MMM yyyy').format(_dates!.end)}',
                        ),
                        onDeleted: () {
                          _dates = null;
                          _apply();
                        },
                      ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: PaginatedReportList(
              key: ValueKey(_revision),
              url: widget.url,
              filters: _filters,
              itemBuilder: widget.itemBuilder,
            ),
          ),
        ],
      ),
    );
  }
}
