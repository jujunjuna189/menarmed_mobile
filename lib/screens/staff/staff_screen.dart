import 'package:flutter/material.dart';
import 'package:menarmed_mobile/repository/staff_repo.dart';
import 'package:url_launcher/url_launcher.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});
  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  List _staffList = [];
  bool _loading = true, _error = false;
  @override
  void initState() {
    super.initState();
    getStaffList();
  }

  Future<void> getStaffList() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final value = await StaffRepo.instance.show({});
      if (mounted)
        setState(() {
          _staffList = value is List ? value : [];
          _error = value is! List;
        });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> openLink(dynamic value) async {
    bool opened = false;
    try {
      final uri = Uri.tryParse(value?.toString() ?? '');
      if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http'))
        opened = await launchUrl(uri);
    } catch (_) {}
    if (!opened && mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tautan tidak dapat dibuka')),
      );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Staff')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: getStaffList,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (_error)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text('Data staff gagal dimuat'),
                        TextButton.icon(
                          onPressed: getStaffList,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  )
                else if (_staffList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('Belum ada data staff')),
                  ),
                ..._staffList.map(
                  (value) => Column(
                    children: [
                      ListTile(
                        tileColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF0F1F2),
                          child: Icon(
                            Icons.business_center_outlined,
                            size: 20,
                            color: Color(0xFF383A3E),
                          ),
                        ),
                        title: Text(
                          value['name']?.toString() ?? '-',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(Icons.open_in_new, size: 18),
                        onTap: () => openLink(value['url']),
                      ),
                      const Divider(height: 1, indent: 56),
                    ],
                  ),
                ),
              ],
            ),
          ),
  );
}
