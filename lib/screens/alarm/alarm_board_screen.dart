import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:menarmed_mobile/repository/firebase/fire_alarm_repo.dart';

class AlarmBoardScreen extends StatefulWidget {
  const AlarmBoardScreen({super.key, required this.data});
  final String data;
  @override
  State<AlarmBoardScreen> createState() => _AlarmBoardScreenState();
}

class _AlarmBoardScreenState extends State<AlarmBoardScreen> {
  late final Map<String, dynamic> _alarm;
  Duration _duration = Duration.zero;
  Timer? _timer;
  bool _running = false;
  bool _busy = false;
  bool _siren = true;
  @override
  void initState() {
    super.initState();
    _alarm = jsonDecode(widget.data) as Map<String, dynamic>;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> toggleAlarm() async {
    if (_busy) return;
    final next = !_running;
    setState(() => _busy = true);
    try {
      await FireAlarmRepo.instance.store({
        'status': next,
        'siren': _siren,
        'alarm': _alarm['title'] ?? '',
        'code': _alarm['code'] ?? '',
      });
      if (!mounted) return;
      _timer?.cancel();
      setState(() {
        _running = next;
        if (next) _duration = Duration.zero;
      });
      if (next) {
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() => _duration += const Duration(seconds: 1));
        });
      }
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alarm gagal diperbarui. Coba lagi.')),
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String digits(int value) => value.toString().padLeft(2, '0');
    final time =
        '${digits(_duration.inHours)}:${digits(_duration.inMinutes.remainder(60))}:${digits(_duration.inSeconds.remainder(60))}';
    return PopScope(
      canPop: !_running && !_busy,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hentikan alarm sebelum meninggalkan halaman'),
            ),
          );
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Alarm Stelling')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            Center(
              child: Image.asset(
                'assets/images/icon/alarm.png',
                width: 64,
                height: 64,
                excludeFromSemantics: true,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _alarm['title']?.toString() ?? 'Alarm',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            if (_alarm['sub_title'] != null) ...[
              const SizedBox(height: 5),
              Text(
                _alarm['sub_title'].toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF73777D)),
              ),
            ],
            const SizedBox(height: 24),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _running
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_none,
                    size: 16,
                    color: _running
                        ? const Color(0xFFB24343)
                        : const Color(0xFF73777D),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _running ? 'Alarm aktif' : 'Alarm tidak aktif',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  time,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Suara sirene'),
              subtitle: const Text(
                'Jika dimatikan, gunakan suara notifikasi biasa. Hentikan alarm sebelum mengubah pilihan.',
              ),
              value: _siren,
              onChanged: _busy || _running
                  ? null
                  : (value) => setState(() => _siren = value),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _busy ? null : toggleAlarm,
              style: FilledButton.styleFrom(
                backgroundColor: _running
                    ? const Color(0xFFB24343)
                    : const Color(0xFF383A3E),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_running ? Icons.stop : Icons.play_arrow),
              label: Text(
                _busy
                    ? 'Memproses...'
                    : _running
                    ? 'Hentikan alarm'
                    : 'Bunyikan alarm',
              ),
            ),
            if (_alarm['description'] != null) ...[
              const SizedBox(height: 28),
              const Divider(height: 1),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 18,
                    color: Color(0xFF73777D),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ketentuan Siaga',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _alarm['description'].toString(),
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Color(0xFF62666C),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
