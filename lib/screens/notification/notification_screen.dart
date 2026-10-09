import 'dart:async';
import 'package:flutter/material.dart';
import 'package:menarmed_mobile/repository/notification_repo.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List _items = [];
  bool _loading = true;
  bool _failed = false;
  int? _expanded;
  Timer? _timer;
  bool _fetching = false;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (_fetching) return;
    _fetching = true;
    try {
      final items = await NotificationRepo.instance.getNotif(orderBy: 'desc');
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
        _failed = false;
      });
    } catch (_) {
      if (mounted)
        setState(() {
          _loading = false;
          _failed = true;
        });
    } finally {
      _fetching = false;
    }
  }

  Future<void> _toggle(Map item) async {
    setState(
      () => _expanded = _expanded == item['id'] ? null : item['id'] as int,
    );
    if (item['read'] == true) return;
    try {
      await NotificationRepo.instance.notificationRead(item['id']);
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status baca gagal disimpan. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = _items.where((item) => item['read'] != true).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            tooltip: 'Perbarui',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$unread belum dibaca · ${_items.length} notifikasi',
                      style: const TextStyle(
                        color: Color(0xFF73777D),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                if (_failed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextButton(
                      onPressed: _load,
                      child: const Text('Gagal memuat notifikasi. Coba lagi'),
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: _items.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(32, 80, 32, 32),
                            children: const [
                              Icon(
                                Icons.notifications_none_outlined,
                                size: 52,
                                color: Color(0xFF989898),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Belum ada notifikasi',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Pemberitahuan yang tersimpan akan muncul di sini.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF73777D)),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: _items.length,
                            separatorBuilder: (_, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = _items[index] as Map;
                              final expanded = _expanded == item['id'];
                              final unread = item['read'] != true;
                              final alarm =
                                  item['code'].toString().split('-').first ==
                                  '0';
                              final subtitle =
                                  item['sub_title']?.toString() ?? '';
                              return Material(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(
                                    color: unread
                                        ? const Color(0xFFD5D5D5)
                                        : const Color(0xFFE9EAEC),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => _toggle(item),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          alarm
                                              ? Icons
                                                    .notifications_active_outlined
                                              : Icons.chat_bubble_outline,
                                          size: 22,
                                          color: alarm
                                              ? const Color(0xFFB24343)
                                              : const Color(0xFF73777D),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                alarm
                                                    ? 'ALARM STELLING'
                                                    : 'PESAN',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  letterSpacing: 0.8,
                                                  color: Color(0xFF73777D),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                item['title']?.toString() ??
                                                    'Notifikasi',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: unread
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                ),
                                              ),
                                              if (subtitle.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  subtitle,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF73777D),
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(height: 8),
                                              Text(
                                                item['content']?.toString() ??
                                                    '',
                                                maxLines: expanded ? null : 2,
                                                overflow: expanded
                                                    ? TextOverflow.visible
                                                    : TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  height: 1.6,
                                                  color: Color(0xFF62666C),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                expanded
                                                    ? 'Tutup detail'
                                                    : 'Baca selengkapnya',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF73777D),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (unread)
                                          const Icon(
                                            Icons.circle,
                                            size: 7,
                                            color: Color(0xFFB24343),
                                          )
                                        else
                                          Icon(
                                            expanded
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                            size: 18,
                                            color: const Color(0xFF989898),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
