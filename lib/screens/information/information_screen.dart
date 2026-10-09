import 'package:flutter/material.dart';
import 'package:menarmed_mobile/repository/auth_repo.dart';
import 'package:menarmed_mobile/widgets/toast/toast_alert.dart';
import 'package:url_launcher/url_launcher.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({Key? key}) : super(key: key);

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  Map<String, dynamic> _user = {};

  @override
  void initState() {
    getFirstData();
    super.initState();
  }

  void getFirstData() async {
    await getUser();
  }

  Future<void> getUser() async {
    final value = await AuthRepo.instance.getSession("user");
    if (!mounted) return;
    setState(() {
      _user = value is Map ? Map<String, dynamic>.from(value) : {};
    });
  }

  void navigation(String routeName) {
    if (_user['role'] == 1 || _user['role'] == '1') {
      Navigator.of(context).pushNamed(routeName);
    } else {
      ToastAlert.instance.showMessage(
        customMessage: true,
        customMessageText: "Hanya yang berwenang",
      );
    }
  }

  Widget _section(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF73777D),
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _menu(
    String title,
    String asset,
    VoidCallback onTap, {
    bool external = false,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: Image.asset('assets/images/icon/$asset'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF24272B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                external ? Icons.open_in_new : Icons.chevron_right,
                size: 18,
                color: const Color(0xFF8A8F95),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPublicService() async {
    try {
      final opened = await launchUrl(
        Uri.parse(
          'https://docs.google.com/spreadsheets/d/1mDJK9RF2mgrq2mC8qk4Qs6MEQ9WaPyODtfrhZGFMcEs/edit?usp=sharing',
        ),
      );
      if (!opened) throw Exception('Gagal membuka tautan');
    } catch (_) {
      if (!mounted) return;
      ToastAlert.instance.showMessage(
        customMessage: true,
        customMessageText: 'Gagal membuka tautan',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF4F5F6),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          _section('Personel', [
            _menu('Absensi', 'note.png', () => navigation('/report_presence')),
            _menu(
              'Perizinan',
              'soldier.png',
              () => navigation('/report_permission'),
            ),
          ]),
          _section('Kendaraan', [
            _menu(
              'Ranpur',
              'armored-van.png',
              () => navigation('/report_vehicle_van_permission'),
            ),
            _menu(
              'Angkutan',
              'armored-vehicle.png',
              () => navigation('/report_vehicle_permission'),
            ),
          ]),
          _section('Perlengkapan', [
            _menu(
              'Gudang Senjata',
              'barracks.png',
              () => navigation('/report_armory'),
            ),
            _menu(
              'Logistik',
              'backpack.png',
              () => navigation('/report_logistics'),
            ),
          ]),
          _section('Layanan', [
            _menu(
              'Saran & Masukan',
              'letterbox.png',
              () => navigation('/report_suggestion'),
            ),
            _menu(
              'Layanan Publik',
              'form-survei.png',
              _openPublicService,
              external: true,
            ),
          ]),
        ],
      ),
    );
  }
}
