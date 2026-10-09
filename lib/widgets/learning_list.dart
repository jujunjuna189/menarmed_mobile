import 'dart:convert';
import 'package:flutter/material.dart';

class LearningList extends StatefulWidget {
  const LearningList({
    super.key,
    required this.load,
    required this.label,
    required this.route,
    required this.icon,
    this.article = false,
  });
  final Future<dynamic> Function() load;
  final String label;
  final String route;
  final IconData icon;
  final bool article;

  @override
  State<LearningList> createState() => _LearningListState();
}

class _LearningListState extends State<LearningList>
    with AutomaticKeepAliveClientMixin {
  List _items = [];
  bool _loading = true;
  bool _failed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final result = await widget.load();
      if (!mounted) return;
      setState(() {
        _items = result is Iterable ? result.toList() : [];
        _failed = result is! Iterable;
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
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_failed)
      return Center(
        child: TextButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text('Coba lagi'),
        ),
      );
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              '${_items.length} ${widget.label.toLowerCase()}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF73777D)),
            ),
          ),
          if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(widget.icon, size: 28, color: const Color(0xFF8A8F95)),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada ${widget.label.toLowerCase()}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF73777D),
                    ),
                  ),
                ],
              ),
            ),
          ..._items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFFE2E4E7)),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.of(context).pushNamed(
                    widget.route,
                    arguments: jsonEncode(
                      widget.article
                          ? {'article_id': item['id']}
                          : {'path': item['path']},
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          widget.icon,
                          size: 22,
                          color: const Color(0xFF555A60),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['judul']?.toString() ?? '-',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF24272B),
                                ),
                              ),
                              if ((item['deskripsi']?.toString() ?? '')
                                  .trim()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 5),
                                Text(
                                  item['deskripsi'].toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: Color(0xFF73777D),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
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
    );
  }
}
