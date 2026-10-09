import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PaginatedReportList extends StatefulWidget {
  const PaginatedReportList({
    super.key,
    required this.url,
    required this.itemBuilder,
    this.client,
    this.filters = const {},
    this.groupByMonth = true,
  });

  final String url;
  final Widget Function(BuildContext, Map<String, dynamic>) itemBuilder;
  final http.Client? client;
  final Map<String, String> filters;
  final bool groupByMonth;

  @override
  State<PaginatedReportList> createState() => _PaginatedReportListState();
}

class _PaginatedReportListState extends State<PaginatedReportList> {
  final _controller = ScrollController();
  final List<Map<String, dynamic>> _items = [];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _load();
  }

  void _onScroll() {
    if (_controller.position.extentAfter <= 0 && !_failed) _load();
  }

  String _monthLabel(Map<String, dynamic> item) {
    final raw = item['created_at']?.toString() ?? '';
    if (raw.isEmpty || raw == '-') return 'Tanggal tidak tersedia';
    DateTime? date = DateTime.tryParse(raw);
    if (date == null) {
      try {
        date = DateFormat(
          'yyyy-MMM-dd',
          'en_US',
        ).parseStrict(raw.split(' ').first);
      } on FormatException {
        return 'Tanggal tidak tersedia';
      }
    }
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Future<void> _load() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final post = widget.client?.post ?? http.post;
      final response = await post(
        Uri.parse(widget.url),
        body: {...widget.filters, 'page': _page.toString(), 'per_page': '10'},
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) throw Exception('Report request failed');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rows = (data['data'] as List)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList();
      final pagination = data['pagination'] as Map<String, dynamic>;
      final currentPage = pagination['current_page'] as int;
      final hasMore = pagination['has_more'] as bool;
      if (currentPage != _page) {
        throw Exception('Unexpected report page');
      }
      if (!mounted) return;
      setState(() {
        _items.addAll(rows);
        _page = currentPage + 1;
        _hasMore = hasMore;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && !_loading && !_failed) {
      return const Center(child: Text('Data kosong'));
    }
    return ListView.builder(
      controller: _controller,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _items.length) {
          final month = _monthLabel(_items[index]);
          final startsMonth =
              index == 0 || month != _monthLabel(_items[index - 1]);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.groupByMonth && startsMonth)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Row(
                    children: [
                      Text(
                        month,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF555A60),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Divider(height: 1, color: Color(0xFFDDE0E3)),
                      ),
                    ],
                  ),
                ),
              widget.itemBuilder(context, _items[index]),
            ],
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: _failed
                ? TextButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba lagi'),
                  )
                : _loading
                ? const CircularProgressIndicator()
                : IconButton(
                    onPressed: _load,
                    tooltip: 'Muat berikutnya',
                    icon: const Icon(Icons.expand_more),
                  ),
          ),
        );
      },
    );
  }
}
