import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:menarmed_mobile/widgets/activity_history.dart';
import 'package:menarmed_mobile/repository/movement_status_repo.dart';
import 'package:menarmed_mobile/repository/auth_repo.dart';
import 'package:menarmed_mobile/repository/logistics_repo.dart';
import 'package:menarmed_mobile/widgets/activity_panel.dart';
import 'package:menarmed_mobile/widgets/toast/toast_alert.dart';
import 'package:menarmed_mobile/widgets/toast/toast_loader.dart';

class LogisticsScreen extends StatefulWidget {
  const LogisticsScreen({Key? key}) : super(key: key);

  @override
  State<LogisticsScreen> createState() => _LogisticsScreenState();
}

class _LogisticsScreenState extends State<LogisticsScreen> {
  int _historyVersion = 0;
  Map<String, dynamic> _user = {};
  final String _codeAccess = "03";
  Map<String, dynamic> _logistics = {};
  bool _statusLogisticsOutToday = false;
  bool _statusLogisticsInToday = false;

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
      getLogisticsToday();
    });
  }

  bool _hasRecordedTime(dynamic value) {
    final time = value?.toString().trim() ?? '';
    return time.isNotEmpty && time != '-';
  }

  Future<void> getLogisticsToday() async {
    if (_user['id'] == null) return;
    try {
      final value = await MovementStatusRepo.active(
        '${Api.server}api/logistik/show',
        _user['id'].toString(),
      );
      if (!mounted) return;
      setState(() {
        _logistics = value;
        _statusLogisticsOutToday = _hasRecordedTime(value['keluar']);
        _statusLogisticsInToday = _hasRecordedTime(value['masuk']);
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
        logisticsRequest(
          userId: _user["id"].toString(),
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
        logisticsRequest(
          userId: _user["id"].toString(),
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

  void logisticsRequest({
    String userId = "",
    bool keluar = false,
    bool masuk = false,
    String qrcode = "",
  }) async {
    ToastLoader.instance.showLoader();
    Map<String, dynamic> dataBatch = {
      "user_id": userId,
      "keluar": keluar ? DateTime.now().toString() : "",
      "masuk": masuk ? DateTime.now().toString() : "",
      "qrcode": qrcode,
    };

    await LogisticsRepo.instance.store(dataBatch).then((value) {
      if (!mounted || value is! Map) return;
      setState(() {
        final active = !_hasRecordedTime(value['masuk']);
        _logistics = active ? Map<String, dynamic>.from(value) : {};
        _statusLogisticsOutToday = active && _hasRecordedTime(value['keluar']);
        _statusLogisticsInToday = false;
        _historyVersion++;
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      elevation: 0,
      title: const Text(
        'Logistik',
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
                title: 'Ambil logistik',
                done: _statusLogisticsOutToday,
                statusText: _statusLogisticsOutToday
                    ? 'Belum dikembalikan'
                    : 'Siap scan',
                onScan: _statusLogisticsOutToday ? null : _take,
                icon: Icons.north_east,
                time: _logistics['keluar'],
                details: _statusLogisticsOutToday ? {} : {},
              ),
              ActivityPanel(
                title: 'Kembalikan logistik',
                done: _statusLogisticsInToday,
                statusText: _statusLogisticsOutToday
                    ? 'Menunggu pengembalian'
                    : 'Belum ada pengambilan',
                onScan: _statusLogisticsOutToday ? _return : null,
                icon: Icons.south_west,
                time: _logistics['masuk'],
                details: _statusLogisticsInToday ? {} : {},
              ),
            ],
          ),
        ),
        if (_user['id'] != null)
          ActivityHistory(
            key: ValueKey('${_user['id']}-$_historyVersion'),
            url: Api.reportLogistik,
            userId: _user['id'].toString(),
          ),
      ],
    ),
  );
}
