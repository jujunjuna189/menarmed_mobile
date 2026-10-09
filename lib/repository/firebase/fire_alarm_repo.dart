import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:menarmed_mobile/widgets/toast/toast_alert.dart';

class FireAlarmRepo {
  FireAlarmRepo._privateContructor();
  static final FireAlarmRepo instance = FireAlarmRepo._privateContructor();

  final DatabaseReference _ref = FirebaseDatabase.instance.ref("alarm/demo");

  Future store(Map<String, dynamic> body) async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token');
    if (token == null || token.isEmpty) throw Exception('Silakan login ulang');
    final response = await http
        .post(
          Uri.parse('${Api.server}api/alarm/store'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'status': body['status'],
            'code': body['code'],
            'siren': body['siren'] ?? true,
          }),
        )
        .timeout(const Duration(seconds: 40));
    if (response.statusCode != 200) throw Exception('Pengiriman alarm gagal');
    if (jsonDecode(response.body)['push_sent'] == false) {
      ToastAlert.instance.showMessage(
        customMessage: true,
        customMessageText: 'Alarm aktif, tetapi push notifikasi gagal dikirim',
      );
    }
  }

  Future onChange({Function? callback}) async {
    _ref.onValue.listen(
      (event) {
        try {
          callback!(event.snapshot.value);
        } catch (e) {
          ToastAlert.instance.showMessage(
            customMessage: true,
            customMessageText: "Belum ada data dalam firebase",
          );
        }
      },
      onError: (error) {
        ToastAlert.instance.showMessage(
          customMessage: true,
          customMessageText: "Error firebase on change",
        );
      },
    );
  }
}
