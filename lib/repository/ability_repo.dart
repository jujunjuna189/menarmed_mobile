import 'package:menarmed_mobile/utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:menarmed_mobile/widgets/toast/toast_alert.dart';
import 'package:menarmed_mobile/widgets/toast/toast_loader.dart';

class AbilityRepo {
  AbilityRepo._privateConstructor();
  static final AbilityRepo instance = AbilityRepo._privateConstructor();

  final _kemampuanShow = Api.kemampuanShow;

  Future show(Map<String, dynamic> body, {http.Client? client}) async {
    try {
      final post = client?.post ?? http.post;
      final response = await post(
        Uri.parse(_kemampuanShow),
        body: body,
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 300) {
        var jsonResponse = jsonDecode(response.body);
        final List iterable = jsonResponse['data'] as List;
        if (iterable.isEmpty) return <String, dynamic>{};
        //return data response
        if (response.statusCode == 200) return iterable.first;
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
