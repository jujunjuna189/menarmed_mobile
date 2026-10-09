import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:menarmed_mobile/widgets/paginated_report_list.dart';

Widget report(MockClient client) => MaterialApp(
  home: Scaffold(
    body: PaginatedReportList(
      url: 'https://example.test/report',
      client: client,
      itemBuilder: (context, row) =>
          SizedBox(height: 100, child: Text('Item ${row['id']}')),
    ),
  ),
);

void main() {
  testWidgets('Unexpected backend page is rejected and can be retried', (
    tester,
  ) async {
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      return http.Response(
        jsonEncode({
          'data': List.generate(10, (i) => {'id': i}),
          'pagination': {'current_page': 1, 'has_more': true},
        }),
        200,
      );
    });
    await tester.pumpWidget(report(client));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1500));
    await tester.pumpAndSettle();
    expect(requests, 2);
    final list = tester.widget<ListView>(find.byType(ListView));
    expect(list.childrenDelegate.estimatedChildCount, 11);
    expect(find.text('Coba lagi'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -1500));
    await tester.pumpAndSettle();
    expect(requests, 2);
  });

  testWidgets('Loads ten first, appends on scroll, stops at the last page', (
    tester,
  ) async {
    final pages = <String>[];
    final client = MockClient((request) async {
      final body = Uri.splitQueryString(request.body);
      pages.add(body['page']!);
      expect(body['per_page'], '10');
      final page = int.parse(body['page']!);
      return http.Response(
        jsonEncode({
          'data': List.generate(
            page == 1 ? 10 : 2,
            (i) => {
              'id': (page - 1) * 10 + i,
              'created_at': page == 2 && i == 1 ? '2026-Sep-30' : '2026-Oct-04',
            },
          ),
          'pagination': {'current_page': page, 'has_more': page == 1},
        }),
        200,
      );
    });
    await tester.pumpWidget(report(client));
    await tester.pumpAndSettle();
    expect(pages, ['1']);
    expect(find.text('Oktober 2026'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -1500));
    await tester.pumpAndSettle();
    expect(pages, ['1', '2']);
    await tester.drag(find.byType(ListView), const Offset(0, -1500));
    await tester.pumpAndSettle();
    expect(find.text('Item 11'), findsOneWidget);
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('Oktober 2026'), findsNothing);
    expect(pages, ['1', '2']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Failed request retries the same page', (tester) async {
    final pages = <String>[];
    final client = MockClient((request) async {
      pages.add(Uri.splitQueryString(request.body)['page']!);
      return pages.length == 1
          ? http.Response('{}', 500)
          : http.Response(
              '{"data":[],"pagination":{"current_page":1,"has_more":false}}',
              200,
            );
    });
    await tester.pumpWidget(report(client));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(pages, ['1', '1']);
    expect(find.text('Data kosong'), findsOneWidget);
  });

  testWidgets('Full last page stops according to backend metadata', (
    tester,
  ) async {
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      return http.Response(
        jsonEncode({
          'data': List.generate(10, (i) => {'id': i}),
          'pagination': {'current_page': 1, 'has_more': false},
        }),
        200,
      );
    });
    await tester.pumpWidget(report(client));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1500));
    await tester.pumpAndSettle();
    expect(requests, 1);
  });
}
