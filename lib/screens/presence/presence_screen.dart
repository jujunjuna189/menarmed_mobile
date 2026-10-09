import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:menarmed_mobile/widgets/activity_history.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:menarmed_mobile/repository/presence_repo.dart';
import 'package:menarmed_mobile/repository/auth_repo.dart';
import 'package:menarmed_mobile/widgets/activity_panel.dart';
import 'package:menarmed_mobile/widgets/popup/popup_presence.dart';
import 'package:menarmed_mobile/widgets/toast/toast_alert.dart';
import 'package:menarmed_mobile/widgets/toast/toast_loader.dart';

class PresenceScreen extends StatefulWidget {
  const PresenceScreen({Key? key}) : super(key: key);

  @override
  State<PresenceScreen> createState() => _PresenceScreenState();
}

class _PresenceScreenState extends State<PresenceScreen> {
  int _historyVersion = 0;
  Map<String, dynamic> _user = {};
  final String _codeAccess = "06";
  Map<String, dynamic> _presence = {};
  bool _statusPresenceToday = false;
  String _latitude = "";
  String _longitude = "";

  @override
  void initState() {
    getUser();
    getCurrentLocation();
    super.initState();
  }

  String dateNowFormatter(String date, String format) {
    final DateTime dateNow = DateTime.parse(date);
    final DateFormat formatter = DateFormat(format);
    String formatDateNow = formatter.format(dateNow);
    return formatDateNow;
  }

  void getUser() async {
    await AuthRepo.instance.getSession("user").then((value) {
      if (!mounted) return;
      setState(() {
        _user = value is Map<String, dynamic> ? value : {};
      });
      getPresenceToday();
    });
  }

  void getCurrentLocation() async {
    await Geolocator.checkPermission().then((value) async {
      if (value == LocationPermission.denied) {
        await Geolocator.requestPermission();
      } else {
        var position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        // var lastPosition = await Geolocator.getLastKnownPosition();
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      }
    });
  }

  Future<void> getPresenceToday() async {
    if (_user['id'] == null) return;
    try {
      final value = await PresenceRepo.instance.today(_user['id'].toString());
      if (!mounted) return;
      setState(() {
        _statusPresenceToday = value != null;
        _presence = value ?? {};
      });
    } catch (_) {
      // Keep the last known status when the server cannot be reached.
      final cached = await AuthRepo.instance.getSession('presence');
      final date = cached is Map
          ? DateTime.tryParse(cached['created_at']?.toString() ?? '')?.toLocal()
          : null;
      final now = DateTime.now();
      if (!mounted ||
          cached is! Map ||
          cached['user_id']?.toString() != _user['id'].toString() ||
          date == null)
        return;
      setState(() {
        _statusPresenceToday =
            date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
        _presence = _statusPresenceToday
            ? Map<String, dynamic>.from(cached)
            : {};
      });
    }
  }

  void onOpenQrCode() async {
    await Navigator.of(context).pushNamed("/scan_qr").then((code) {
      if (!mounted || code == null) return;
      String json = jsonDecode(code.toString()).toString();
      var splitText = json.split("-");
      if (_codeAccess == splitText.first) {
        onPresence(qrcode: json);
      } else {
        ToastAlert.instance.showMessage(
          customMessage: true,
          customMessageText: "Kode tidak sesuai",
        );
      }
    });
  }

  void onPresence({String qrcode = ""}) {
    PopupPresence.instance.showPopup(
      context,
      callback: ((value) {
        ToastLoader.instance.showLoader();
        getCurrentLocation();
        String ket = value['ket'];

        Map<String, dynamic> dataBatch = {
          'user_id': _user['id'].toString(),
          'ket': ket,
          'latitude': _latitude,
          'longitude': _longitude,
          'qrcode': qrcode,
        };

        onExecute(dataBatch);
      }),
    );
  }

  Future<void> onExecute(Map<String, dynamic> dataBatch) async {
    final value = await PresenceRepo.instance.store(dataBatch);
    if (!mounted || value is! Map) return;
    setState(() {
      _presence = Map<String, dynamic>.from(value);
      _statusPresenceToday = true;
      _historyVersion++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Absensi Personil')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                ActivityIdentity(name: _user['name']?.toString() ?? ''),
                ActivityPanel(
                  title: 'Scan absensi',
                  done: _statusPresenceToday,
                  icon: Icons.fact_check_outlined,
                  onScan: onOpenQrCode,
                  time: _statusPresenceToday
                      ? _presence['created_at']?.toString()
                      : null,
                  details: {
                    'Status': _statusPresenceToday
                        ? 'Sudah absen'
                        : 'Belum absen',
                    if (_statusPresenceToday) 'Keterangan': _presence['ket'],
                  },
                ),
              ],
            ),
          ),

          if (_user['id'] != null)
            ActivityHistory(
              key: ValueKey('${_user['id']}-$_historyVersion'),
              url: Api.reportAbsensi,
              userId: _user['id'].toString(),
            ),
        ],
      ),
    );
  }
}
