import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:menarmed_mobile/widgets/activity_history.dart';
import 'package:menarmed_mobile/repository/movement_status_repo.dart';
import 'package:menarmed_mobile/repository/auth_repo.dart';
import 'package:menarmed_mobile/repository/vehicle_van_permission_repo.dart';
import 'package:menarmed_mobile/widgets/activity_panel.dart';
import 'package:menarmed_mobile/widgets/popup/popup_permission.dart';
import 'package:menarmed_mobile/widgets/toast/toast_alert.dart';
import 'package:menarmed_mobile/widgets/toast/toast_loader.dart';

class VehicleVanPermissionScreen extends StatefulWidget {
  const VehicleVanPermissionScreen({Key? key}) : super(key: key);

  @override
  State<VehicleVanPermissionScreen> createState() =>
      _VehicleVanPermissionScreenState();
}

class _VehicleVanPermissionScreenState
    extends State<VehicleVanPermissionScreen> {
  int _historyVersion = 0;
  Map<String, dynamic> _user = {};
  final String _codeAccess = "04";
  Map<String, dynamic> _permission = {};
  bool _statusPermissionOutToday = false;
  bool _statusPermissionInToday = false;

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
      getPermissionToday();
    });
  }

  bool _hasRecordedTime(dynamic value) {
    final time = value?.toString().trim() ?? '';
    return time.isNotEmpty && time != '-';
  }

  Future<void> getPermissionToday() async {
    if (_user['id'] == null) return;
    try {
      final value = await MovementStatusRepo.active(
        '${Api.server}api/perizinan/ranpur/show',
        _user['id'].toString(),
      );
      if (!mounted) return;
      setState(() {
        _permission = value;
        _statusPermissionOutToday = _hasRecordedTime(value['keluar']);
        _statusPermissionInToday = _hasRecordedTime(value['masuk']);
      });
    } catch (_) {
      if (mounted)
        ToastAlert.instance.showMessage(
          customMessage: true,
          customMessageText: 'Status aktivitas gagal dimuat',
        );
    }
  }

  void permissionOut() async {
    await Navigator.of(context).pushNamed("/scan_qr").then((code) {
      if (!mounted || code == null) return;
      String json = jsonDecode(code.toString()).toString();
      var splitText = json.split("-");
      if (_codeAccess == splitText.first) {
        PopupPermission.instance.showPopup(
          context,
          vehicle: true,
          callback: ((value) {
            permissionRequest(
              userId: _user["id"].toString(),
              keluar: true,
              tujuan: value["destination"],
              jenisKendaraan: value["type_vihicle"],
              qrcode: json,
            );
          }),
        );
      } else {
        ToastAlert.instance.showMessage(
          customMessage: true,
          customMessageText: "Kode tidak sesuai",
        );
      }
    });
  }

  void permissionIn() async {
    await Navigator.of(context).pushNamed("/scan_qr").then((code) {
      if (!mounted || code == null) return;
      String json = jsonDecode(code.toString()).toString();
      var splitText = json.split("-");
      if (_codeAccess == splitText.first) {
        permissionRequest(
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

  void permissionRequest({
    String userId = "",
    bool keluar = false,
    bool masuk = false,
    String tujuan = "",
    String jenisKendaraan = "",
    String qrcode = "",
  }) async {
    ToastLoader.instance.showLoader();
    Map<String, dynamic> dataBatch = {
      "user_id": userId,
      "keluar": keluar ? DateTime.now().toString() : "",
      "masuk": masuk ? DateTime.now().toString() : "",
      "tujuan": tujuan,
      "jenis_kendaraan": jenisKendaraan,
      "qrcode": qrcode,
    };

    await VehicleVanPermissionRepo.instance.store(dataBatch).then((value) {
      if (!mounted || value is! Map) return;
      setState(() {
        final active = !_hasRecordedTime(value['masuk']);
        _permission = active ? Map<String, dynamic>.from(value) : {};
        _statusPermissionOutToday = active && _hasRecordedTime(value['keluar']);
        _statusPermissionInToday = false;
        _historyVersion++;
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      elevation: 0,
      title: const Text(
        'Ranpur',
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
                title: 'Ranpur keluar',
                done: _statusPermissionOutToday,
                statusText: _statusPermissionOutToday
                    ? 'Sedang di luar'
                    : 'Siap scan',
                onScan: _statusPermissionOutToday ? null : permissionOut,
                icon: Icons.north_east,
                time: _permission['keluar'],
                details: _statusPermissionOutToday
                    ? {
                        'Tujuan': _permission['tujuan'],
                        if (_permission['jenis_kendaraan'] != null)
                          'Kendaraan': _permission['jenis_kendaraan'],
                      }
                    : {},
              ),
              ActivityPanel(
                title: 'Ranpur masuk',
                done: _statusPermissionInToday,
                statusText: _statusPermissionOutToday
                    ? 'Menunggu masuk'
                    : 'Belum ada izin keluar',
                onScan: _statusPermissionOutToday ? permissionIn : null,
                icon: Icons.south_west,
                time: _permission['masuk'],
                details: _statusPermissionInToday ? {} : {},
              ),
            ],
          ),
        ),
        if (_user['id'] != null)
          ActivityHistory(
            key: ValueKey('${_user['id']}-$_historyVersion'),
            url: Api.reportPerizinanRanpur,
            userId: _user['id'].toString(),
          ),
      ],
    ),
  );
}
