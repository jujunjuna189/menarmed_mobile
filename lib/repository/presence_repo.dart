import 'package:menarmed_mobile/repository/auth_repo.dart';
import 'package:menarmed_mobile/utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:menarmed_mobile/widgets/toast/toast_alert.dart';
import 'package:menarmed_mobile/widgets/toast/toast_loader.dart';

class PresenceRepo {
  PresenceRepo._privateConstructor();
  static final PresenceRepo instance = PresenceRepo._privateConstructor();

  final _absensiStore = Api.absensiStore;
  final _reportAbsensi = Api.reportAbsensi;

  Future<Map<String, dynamic>?> today(
    String userId, {
    http.Client? client,
  }) async {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final post = client?.post ?? http.post;
    final response = await post(
      Uri.parse(_reportAbsensi),
      body: {
        'user_id': userId,
        'date_from': date,
        'date_to': date,
        'page': '1',
        'per_page': '1',
      },
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) throw Exception('Presence status failed');
    final rows = jsonDecode(response.body)['data'] as List;
    return rows.isEmpty ? null : Map<String, dynamic>.from(rows.first);
  }

  Future report(Map<String, dynamic> body) async {
    try {
      final response = await http.post(Uri.parse(_reportAbsensi), body: body);

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
      final response = await http.post(Uri.parse(_absensiStore), body: body);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        Iterable iterable = jsonResponse['data'];
        //Set session presence with today
        await AuthRepo.instance.setSession(
          "presence",
          Map<String, dynamic>.from(iterable.first),
        );
        //return data response
        ToastLoader.instance.hideLoader();
        ToastAlert.instance.showMessage(success: true);
        return iterable.first;
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
