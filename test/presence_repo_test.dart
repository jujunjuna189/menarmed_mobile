import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:menarmed_mobile/repository/presence_repo.dart';

void main() {
  test('Today status requests the current user and day', () async {
    final client = MockClient((request) async {
      final body = request.bodyFields;
      expect(body['user_id'], '7');
      expect(body['date_from'], body['date_to']);
      expect(body['page'], '1');
      expect(body['per_page'], '1');
      return http.Response(
        jsonEncode({
          'data': [
            {'id': 1, 'ket': 'Hadir'},
          ],
        }),
        200,
      );
    });
    addTearDown(client.close);
    expect(
      (await PresenceRepo.instance.today('7', client: client))!['ket'],
      'Hadir',
    );
  });
  test('No attendance today returns null', () async {
    final client = MockClient((_) async => http.Response('{"data":[]}', 200));
    addTearDown(client.close);
    expect(await PresenceRepo.instance.today('7', client: client), isNull);
  });
}
