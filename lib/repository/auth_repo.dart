import 'package:menarmed_mobile/service/push_token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:menarmed_mobile/widgets/toast/toast_alert.dart';
import 'package:menarmed_mobile/widgets/toast/toast_loader.dart';

class AuthRepo{
  AuthRepo._privateContructor();
  static final AuthRepo instance = AuthRepo._privateContructor();

  final _uriLogin = Api.login;
  final _uriRegister = Api.register;

  Future<bool> login(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(_uriLogin),
        headers: const {'Accept': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 15));
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final data = jsonResponse['data'] as List<dynamic>;
        await setSession("user", Map<String, dynamic>.from(data.first as Map));
        await setStringSession("auth_token", jsonResponse['token'].toString());
        PushTokenService.instance.signedIn();
        ToastLoader.instance.hideLoader();
        ToastAlert.instance.showMessage(
          customMessage: true,
          customMessageText: jsonResponse['message']?.toString() ?? "Berhasil masuk",
        );
        return true;
      }

      ToastLoader.instance.hideLoader();
      ToastAlert.instance.showMessage(
        customMessage: true,
        customMessageText: jsonResponse['message']?.toString() ?? "NRP atau password tidak sesuai",
      );
      return false;
    } on TimeoutException {
      ToastLoader.instance.hideLoader();
      ToastAlert.instance.showMessage(
        customMessage: true,
        customMessageText: "Koneksi ke server habis waktu",
      );
      return false;
    } catch (_) {
      ToastLoader.instance.hideLoader();
      ToastAlert.instance.showMessage(serverError: true);
      return false;
    }
  }

  Future register(Map<String, dynamic> body) async {
    try {
      final response = await http.post(Uri.parse(_uriRegister), body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);
        Iterable iterable = jsonResponse['data'];
        //Set session
        await setSession("user", Map<String, dynamic>.from(iterable.first));
        await setStringSession("auth_token", jsonResponse['token'].toString());
        PushTokenService.instance.signedIn();
        ToastLoader.instance.hideLoader();
        ToastAlert.instance.showMessage(customMessage: true, customMessageText: "Berhasil daftar akun");
        return true;
      }
    } catch (e) {
      ToastLoader.instance.hideLoader();
      ToastAlert.instance.showMessage(serverError: true);
    }
    ToastLoader.instance.hideLoader();
    ToastAlert.instance.showMessage(customMessage: true, customMessageText: "Gagal daftar akun");
    return false;
  }

  Future logout() async {
    final preference = await SharedPreferences.getInstance();
    await PushTokenService.instance.unregister();
    final installation = preference.getString('push_installation_id');
    await preference.clear();
    if (installation != null) {
      await preference.setString('push_installation_id', installation);
    }
    // preference.remove("user");
    ToastLoader.instance.hideLoader();
    ToastAlert.instance.showMessage(customMessage: true, customMessageText: "Berhasil keluar aplikasi");
    return true;
  }

  Future<void> setSession(String key, Map<String, dynamic> value) async {
    final preference = await SharedPreferences.getInstance();
    if (preference.containsKey(key)) {
      preference.remove(key);
    }
    await preference.setString(key, jsonEncode(value));
  }

  Future<void> setStringSession(String key, String value) async {
    final preference = await SharedPreferences.getInstance();
    await preference.setString(key, value);
  }

  Future getSession(String key) async {
    final preference = await SharedPreferences.getInstance();
    if (preference.containsKey(key)) {
      final data = jsonDecode(preference.getString(key).toString());
      return data;
    } else {
      return null;
    }
  }

  Future removeSession(String key) async {
    final preference = await SharedPreferences.getInstance();
    if (preference.containsKey(key)) {
      preference.remove(key);
      return true;
    } else {
      return false;
    }
  }
}
