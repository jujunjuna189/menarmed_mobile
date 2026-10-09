import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:menarmed_mobile/widgets/report_entry.dart';

class ActivityHistory extends StatefulWidget {
  const ActivityHistory({
    super.key,
    required this.url,
    required this.userId,
    this.armory = false,
  });
  final String url;
  final String userId;
  final bool armory;
  @override
  State<ActivityHistory> createState() => _ActivityHistoryState();
}

class _ActivityHistoryState extends State<ActivityHistory> {
  final List<Map<String, dynamic>> _items = [];
  bool _loading = false, _failed = false, _more = true;
  int _page = 1;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading || !_more) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final response = await http
          .post(
            Uri.parse(widget.url),
            body: {
              'user_id': widget.userId,
              'page': _page.toString(),
              'per_page': '10',
            },
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) throw Exception('History failed');
      final data = jsonDecode(response.body) as Map;
      final pagination = data['pagination'] as Map;
      if (pagination['current_page'] != _page)
        throw Exception('Unexpected page');
      final rows = (data['data'] as List)
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
      if (!mounted) return;
      setState(() {
        _items.addAll(rows);
        _page++;
        _more = pagination['has_more'] as bool;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 4),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.history, size: 18, color: Color(0xFF65676B)),
            SizedBox(width: 8),
            Text(
              'Riwayat Saya',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      ..._items.map(
        (item) =>
            ReportEntry(data: item, fullWidth: true, armory: widget.armory),
      ),
      if (_items.isEmpty && !_loading && !_failed)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Text(
            'Belum ada riwayat',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
      if (_loading)
        const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        )
      else if (_failed)
        TextButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text('Gagal memuat riwayat. Coba lagi'),
        )
      else if (_more)
        TextButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.expand_more),
          label: const Text('Muat berikutnya'),
        ),
    ],
  );
}
