import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:menarmed_mobile/repository/ability_repo.dart';

void main() {
  for (final status in [200, 300]) {
    test(
      'Empty ability response $status is an empty map, not failure',
      () async {
        final client = MockClient(
          (_) async => http.Response(jsonEncode({'data': []}), status),
        );
        addTearDown(client.close);
        final result = await AbilityRepo.instance.show({
          'user_id': '7',
        }, client: client);
        expect(result, isEmpty);
        expect(result, isA<Map<String, dynamic>>());
      },
    );
  }
  test('Existing ability is preserved', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'data': [
            {'lari': '12'},
          ],
        }),
        200,
      ),
    );
    addTearDown(client.close);
    expect(await AbilityRepo.instance.show({'user_id': '7'}, client: client), {
      'lari': '12',
    });
  });
}
