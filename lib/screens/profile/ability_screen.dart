import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:menarmed_mobile/repository/ability_repo.dart';

class AbilityScreen extends StatefulWidget {
  final String data;
  const AbilityScreen({super.key, required this.data});
  @override
  State<AbilityScreen> createState() => _AbilityScreenState();
}

class _AbilityScreenState extends State<AbilityScreen> {
  Map _ability = {};
  Map _personnel = {};
  bool _loading = true, _error = false;
  @override
  void initState() {
    super.initState();
    getAbility();
  }

  Future<void> getAbility() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final argument = jsonDecode(widget.data);
      _personnel = argument is Map ? argument : {};
      final value = await AbilityRepo.instance.show({
        'user_id': argument['user_id'].toString(),
      });
      if (mounted) {
        setState(() {
          _ability = value is Map ? value : {};
          _error = value == false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget section(String title, IconData icon, Map<String, String> fields) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 17, color: const Color(0xFF686B70)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF686B70),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...fields.entries.map(
            (entry) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFEEEFF1))),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    _fieldIcon(entry.key),
                    size: 18,
                    color: const Color(0xFF787B80),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Text(
                      _ability[entry.key]?.toString().trim().isNotEmpty == true
                          ? _ability[entry.key].toString()
                          : '-',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF30343B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
  IconData _fieldIcon(String key) {
    switch (key) {
      case 'lari':
        return Icons.directions_run;
      case 'renang':
        return Icons.pool_outlined;
      case 'shutle_run':
        return Icons.swap_horiz;
      case 'jatri':
      case 'jatrat':
      case 'pistol':
        return Icons.gps_fixed;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kemampuan Personel')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: getAbility,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (_personnel['name'] != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                            color: Color(0xFF55585E),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _personnel['name'].toString(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_personnel['pangkat']
                                      ?.toString()
                                      .isNotEmpty ==
                                  true) ...[
                                const SizedBox(height: 3),
                                Text(
                                  _personnel['pangkat'].toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF787B80),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_error)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text('Data kemampuan gagal dimuat'),
                        TextButton.icon(
                          onPressed: getAbility,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  )
                else if (_ability.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 48,
                    ),
                    child: Column(
                      children: [
                        ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF9DA3AA),
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            'assets/images/illustration/no_data.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                            excludeFromSemantics: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Belum ada data kemampuan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF55585E),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  section('Kesamaptaan', Icons.fitness_center, {
                    'lari': 'Lari',
                    'renang': 'Renang',
                    'push_up': 'Push Up',
                    'sit_up': 'Sit Up',
                    'pull_up': 'Pull Up',
                    'shutle_run': 'Shuttle Run',
                  }),
                  section('Menembak', Icons.gps_fixed, {
                    'jatri': 'Jatri',
                    'jatrat': 'Jatrat',
                    'pistol': 'Pistol',
                  }),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
  );
}
