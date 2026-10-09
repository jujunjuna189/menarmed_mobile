import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:menarmed_mobile/repository/notification_repo.dart';

class PopupNotification {
  PopupNotification._privateConstructor();
  static final instance = PopupNotification._privateConstructor();

  void showPopup(BuildContext context, {String data = '', Function? callback}) {
    final thisContext = context;
    final notifications = data.isEmpty ? <dynamic>[] : jsonDecode(data) as List;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF4F5F6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) {
          final unread = notifications
              .where((item) => item['read'] != true)
              .length;
          return SafeArea(
            top: false,
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.72,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 12, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Notifikasi',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                unread == 0
                                    ? 'Semua notifikasi sudah dibaca'
                                    : '$unread notifikasi belum dibaca',
                                style: const TextStyle(
                                  color: Color(0xFF73777D),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Tutup',
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: notifications.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.notifications_none_rounded,
                                    size: 56,
                                    color: Color(0xFF989898),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Belum ada notifikasi',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Informasi dan pemberitahuan alarm akan muncul di sini.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF73777D),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemCount: notifications.length,
                            separatorBuilder: (_, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = notifications[index];
                              final unread = item['read'] != true;
                              final alarm =
                                  item['code'].toString().split('-').first ==
                                  '0';
                              final subtitle =
                                  item['sub_title']?.toString() ?? '';
                              return Material(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: unread
                                        ? const Color(0xFFD5D5D5)
                                        : const Color(0xFFE9EAEC),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () async {
                                    await NotificationRepo.instance
                                        .notificationRead(item['id']);
                                    if (!context.mounted) return;
                                    setState(() => item['read'] = true);
                                    callback?.call();
                                    Navigator.pop(sheetContext);
                                    if (alarm) {
                                      Navigator.of(thisContext).pushNamed(
                                        '/alarm_description',
                                        arguments: jsonEncode(item),
                                      );
                                    } else {
                                      showDialog<void>(
                                        context: thisContext,
                                        builder: (context) => AlertDialog(
                                          title: Text(
                                            item['title']?.toString() ??
                                                'Notifikasi',
                                          ),
                                          content: SingleChildScrollView(
                                            child: Text(
                                              item['content']?.toString() ?? '',
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Tutup'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: alarm
                                                ? const Color(0xFFFBEDED)
                                                : const Color(0xFFF0F1F3),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            alarm
                                                ? Icons
                                                      .notifications_active_outlined
                                                : Icons.chat_bubble_outline,
                                            size: 22,
                                            color: alarm
                                                ? const Color(0xFFB24343)
                                                : const Color(0xFF62666C),
                                          ),
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
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                item['title']?.toString() ??
                                                    'Notifikasi',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
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
                                              const SizedBox(height: 6),
                                              Text(
                                                item['content']?.toString() ??
                                                    '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  height: 1.5,
                                                  color: Color(0xFF62666C),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (unread)
                                          const Padding(
                                            padding: EdgeInsets.only(top: 4),
                                            child: Icon(
                                              Icons.circle,
                                              size: 8,
                                              color: Color(0xFFB24343),
                                            ),
                                          )
                                        else
                                          const Icon(
                                            Icons.chevron_right,
                                            size: 18,
                                            color: Color(0xFF989898),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
