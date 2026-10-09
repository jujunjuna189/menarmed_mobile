import 'package:menarmed_mobile/repository/auth_repo.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:menarmed_mobile/widgets/toast/toast_alert.dart';
import 'package:menarmed_mobile/widgets/toast/toast_loader.dart';

class LogisticsRepo {
  LogisticsRepo._privateConstructor();
  static final LogisticsRepo instance = LogisticsRepo._privateConstructor();

  final _logistikStore = Api.logistikStore;
  final _reportLogistik = Api.reportLogistik;

  Future report(Map<String, dynamic> body) async {
    try {
      final response = await http.post(Uri.parse(_reportLogistik), body: body);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        Iterable iterable = jsonResponse['data'];
        //return data response
        ToastLoader.instance.hideLoader();
        return iterable;
      }
    } catch (e) {
      ToastLoader.instance.hideLoader();
      ToastAlert.instance.showMessage(serverError: true);
    }
    ToastLoader.instance.hideLoader();
    ToastAlert.instance.showMessage(failed: true);
    return false;
  }

  Future store(Map<String, dynamic> body) async {
    try {
      final response = await http.post(Uri.parse(_logistikStore), body: body);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        Iterable iterable = jsonResponse['data'];
        //Set session permission with today
        await AuthRepo.instance.setSession(
          "logistics",
          Map<String, dynamic>.from(iterable.first),
        );
        //return data response
        ToastLoader.instance.hideLoader();
        ToastAlert.instance.showMessage(success: true);
        return iterable.first;
      }
      if (response.statusCode == 409 || response.statusCode == 422) {
        ToastLoader.instance.hideLoader();
        ToastAlert.instance.showMessage(
          customMessage: true,
          customMessageText:
              jsonDecode(response.body)['message']?.toString() ??
              'Aktivitas tidak dapat diproses',
        );
        return false;
      }
    } catch (e) {
      ToastLoader.instance.hideLoader();
      ToastAlert.instance.showMessage(serverError: true);
    }
    ToastLoader.instance.hideLoader();
    ToastAlert.instance.showMessage(failed: true);
    return false;
  }
}
