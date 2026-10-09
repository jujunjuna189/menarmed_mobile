import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menarmed_mobile/screens/position/detail_position_screen.dart';

void main() {
  testWidgets('Short names and missing fields are safe', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: DetailPositionScreen(data: jsonEncode({'nama': 'A'}))),
    );
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Pangkat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Long identity fields fit a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: DetailPositionScreen(
          data: jsonEncode({
            'nama': 'Nama Personel Yang Sangat Panjang Untuk Pemeriksaan',
            'jabatan': 'Jabatan personel dengan keterangan yang sangat panjang',
            'pangkat': 'Letnan Kolonel',
            'nrp': '123456789012345678901234567890',
          }),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
