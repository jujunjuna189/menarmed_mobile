import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menarmed_mobile/screens/alarm/alarm_screen.dart';
import 'package:menarmed_mobile/screens/alarm/alarm_board_screen.dart';

void main() {
  testWidgets('Alarm list navigates with title, code and instructions', (
    tester,
  ) async {
    String? argument;
    await tester.pumpWidget(
      MaterialApp(
        home: const AlarmScreen(),
        onGenerateRoute: (settings) {
          argument = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => AlarmBoardScreen(data: argument!),
          );
        },
      ),
    );
    await tester.tap(find.text('Awan Jingga'));
    await tester.pumpAndSettle();
    expect(jsonDecode(argument!)['code'], 0);
    expect(find.text('Alarm tidak aktif'), findsOneWidget);
    expect(find.text('Bunyikan alarm'), findsOneWidget);
    expect(find.text('Ketentuan Siaga'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Alarm controls fit narrow screen with larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: AlarmBoardScreen(
          data: jsonEncode({
            'title': 'Angin Puyuh',
            'sub_title': 'Siap Digerakan Sewaktu Waktu',
            'code': 4,
            'description':
                'Menggunakan PDL II tanpa senjata, draghriem dan baret',
          }),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('00:00:00'), findsOneWidget);
  });
}
