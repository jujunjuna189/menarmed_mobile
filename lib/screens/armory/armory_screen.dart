import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:menarmed_mobile/widgets/activity_history.dart';
import 'package:menarmed_mobile/repository/movement_status_repo.dart';
import 'package:menarmed_mobile/repository/armory_repo.dart';
import 'package:menarmed_mobile/repository/auth_repo.dart';
import 'package:menarmed_mobile/widgets/activity_panel.dart';
import 'package:menarmed_mobile/widgets/toast/toast_alert.dart';
import 'package:menarmed_mobile/widgets/toast/toast_loader.dart';

class ArmoryScreen extends StatefulWidget {
  const ArmoryScreen({Key? key}) : super(key: key);

  @override
  State<ArmoryScreen> createState() => _ArmoryScreenState();
}

class _ArmoryScreenState extends State<ArmoryScreen> {
  int _historyVersion = 0;
  Map<String, dynamic> _user = {};
  final String _codeAccess = "02";
  Map<String, dynamic> _armory = {};
  bool _statusArmoryOutToday = false;
  bool _statusArmoryInToday = false;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  void getUser() async {
    await AuthRepo.instance.getSession("user").then((value) {
      if (!mounted) return;
      setState(() {
        _user = value is Map ? Map<String, dynamic>.from(value) : {};
      });
      getArmoryToday();
    });
  }

  bool _hasRecordedTime(dynamic value) {
    final time = value?.toString().trim() ?? '';
    return time.isNotEmpty && time != '-';
  }

  Future<void> getArmoryToday() async {
    if (_user['id'] == null) return;
    try {
      final value = await MovementStatusRepo.active(
        '${Api.server}api/gudang_senjata/show',
        _user['id'].toString(),
      );
      if (!mounted) return;
      setState(() {
        _armory = value;
        _statusArmoryOutToday = _hasRecordedTime(value['keluar']);
        _statusArmoryInToday = _hasRecordedTime(value['masuk']);
      });
    } catch (_) {
      if (mounted)
        ToastAlert.instance.showMessage(
          customMessage: true,
          customMessageText: 'Status aktivitas gagal dimuat',
        );
    }
  }

  void _take() async {
    await Navigator.of(context).pushNamed("/scan_qr").then((code) {
      if (!mounted || code == null) return;
      String json = jsonDecode(code.toString()).toString();
      var splitText = json.split("-");
      if (_codeAccess == splitText.first) {
        String batrai = splitText.length > 1 ? splitText[1].toString() : "";
        armoryRequest(
          userId: _user["id"].toString(),
          batraiKeluar: batrai,
          keluar: true,
          qrcode: json,
        );
      } else {
        ToastAlert.instance.showMessage(
          customMessage: true,
          customMessageText: "Kode tidak sesuai",
        );
      }
    });
  }

  void _return() async {
    await Navigator.of(context).pushNamed("/scan_qr").then((code) {
      if (!mounted || code == null) return;
      String json = jsonDecode(code.toString()).toString();
      var splitText = json.split("-");
      if (_codeAccess == splitText.first) {
        String batrai = splitText.length > 1 ? splitText[1].toString() : "";
        armoryRequest(
          userId: _user["id"].toString(),
          batraiMasuk: batrai,
          masuk: true,
          qrcode: json,
        );
      } else {
        ToastAlert.instance.showMessage(
          customMessage: true,
          customMessageText: "Kode tidak sesuai",
        );
      }
    });
  }

  void armoryRequest({
    String userId = "",
    String batraiKeluar = "",
    String batraiMasuk = "",
    bool keluar = false,
    bool masuk = false,
    String qrcode = "",
  }) async {
    ToastLoader.instance.showLoader();
    Map<String, dynamic> dataBatch = {
      "user_id": userId,
      "batrai_keluar": batraiKeluar,
      "batrai_masuk": batraiMasuk,
      "keluar": keluar ? DateTime.now().toString() : "",
      "masuk": masuk ? DateTime.now().toString() : "",
      "qrcode": qrcode,
    };

    await ArmoryRepo.instance.store(dataBatch).then((value) {
      if (!mounted || value is! Map) return;
      setState(() {
        final active = !_hasRecordedTime(value['masuk']);
        _armory = active ? Map<String, dynamic>.from(value) : {};
        _statusArmoryOutToday = active && _hasRecordedTime(value['keluar']);
        _statusArmoryInToday = false;
        _historyVersion++;
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      elevation: 0,
      title: const Text(
        'Gudang Senjata',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              ActivityIdentity(name: _user['name']?.toString() ?? ''),
              ActivityPanel(
                title: 'Ambil senjata',
                done: _statusArmoryOutToday,
                statusText: _statusArmoryOutToday
                    ? 'Belum dikembalikan'
                    : 'Siap scan',
                onScan: _statusArmoryOutToday ? null : _take,
                icon: Icons.north_east,
                time: _armory['keluar'],
                details: _statusArmoryOutToday
                    ? {'Batrai': _armory['batrai_keluar']}
                    : {},
              ),
              ActivityPanel(
                title: 'Kembalikan senjata',
                done: _statusArmoryInToday,
                statusText: _statusArmoryOutToday
                    ? 'Menunggu pengembalian'
                    : 'Belum ada pengambilan',
                onScan: _statusArmoryOutToday ? _return : null,
                icon: Icons.south_west,
                time: _armory['masuk'],
                details: _statusArmoryInToday
                    ? {'Batrai': _armory['batrai_masuk']}
                    : {},
              ),
            ],
          ),
        ),
        if (_user['id'] != null)
          ActivityHistory(
            key: ValueKey('${_user['id']}-$_historyVersion'),
            url: Api.reportGudangSenjata,
            userId: _user['id'].toString(),
            armory: true,
          ),
      ],
    ),
  );
}
