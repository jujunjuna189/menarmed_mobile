import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityIdentity extends StatelessWidget {
  const ActivityIdentity({super.key, required this.name});
  final String name;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.person_outline,
            size: 22,
            color: Color(0xFF45484D),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? 'Personil' : name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                DateFormat('dd MMM yyyy').format(DateTime.now()),
                style: const TextStyle(fontSize: 12, color: Color(0xFF7A7C80)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class ActivityPanel extends StatelessWidget {
  const ActivityPanel({
    super.key,
    required this.title,
    required this.done,
    required this.onScan,
    required this.icon,
    this.time,
    this.details = const {},
    this.statusText,
  });
  final String title;
  final bool done;
  final VoidCallback? onScan;
  final IconData icon;
  final dynamic time;
  final Map<String, dynamic> details;
  final String? statusText;
  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(time?.toString() ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8E9EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F1F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 19, color: const Color(0xFF55585E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: done
                        ? const Color(0xFFEDF3EF)
                        : const Color(0xFFF1F2F4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText ?? (done ? 'Tercatat' : 'Belum tercatat'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: done
                          ? const Color(0xFF507360)
                          : const Color(0xFF75787E),
                    ),
                  ),
                ),
                if (done && date != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        done ? Icons.check_circle_outline : Icons.schedule,
                        size: 13,
                        color: done
                            ? const Color(0xFF507360)
                            : const Color(0xFF929499),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          DateFormat('HH:mm:ss').format(date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7A7C80),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                ...details.entries
                    .where(
                      (entry) =>
                          entry.key != 'Status' &&
                          entry.value != null &&
                          entry.value.toString().isNotEmpty,
                    )
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.notes_outlined,
                              size: 14,
                              color: Color(0xFF7A7C80),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '${entry.key}: ${entry.value}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7A7C80),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              tooltip: title,
              onPressed: onScan,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF383A3E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              icon: const Icon(Icons.qr_code_scanner, size: 21),
            ),
          ),
        ],
      ),
    );
  }
}
