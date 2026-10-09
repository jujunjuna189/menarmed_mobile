import 'dart:async';
import 'package:flutter/material.dart';
import 'package:menarmed_mobile/repository/notification_repo.dart';

class NotifNotification extends StatefulWidget {
  const NotifNotification({super.key});
  @override
  State<NotifNotification> createState() => _NotifNotificationState();
}

class _NotifNotificationState extends State<NotifNotification> {
  int _unread = 0;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final items = await NotificationRepo.instance.getNotif();
    if (!mounted) return;
    final count = items.where((item) => item['read'] != true).length;
    if (count != _unread) setState(() => _unread = count);
  }

  Future<void> _open() async {
    await Navigator.of(context).pushNamed('/notifications');
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: _unread == 0 ? 'Notifikasi' : '$_unread notifikasi belum dibaca',
      onPressed: _open,
      icon: Badge(
        isLabelVisible: _unread > 0,
        backgroundColor: const Color(0xFFB24343),
        label: Text(_unread > 99 ? '99+' : '$_unread'),
        child: const Icon(Icons.notifications_none_outlined),
      ),
    );
  }
}
