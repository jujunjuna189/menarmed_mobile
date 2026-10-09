import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menarmed_mobile/widgets/report_entry.dart';

void main() {
  testWidgets('Armory details fit a narrow viewport with enlarged text', (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: Scaffold(body: SingleChildScrollView(child: ReportEntry(
          armory: true,
          data: {
            'user_name': 'Nama Personel Sangat Panjang Untuk Pemeriksaan Layout',
            'created_at': '2026-Oct-04',
            'keluar': '08:30:00', 'masuk': '-',
            'batrai_keluar': 'Baterai dengan keterangan panjang',
            'batrai_masuk': '-',
          },
        ))),
      ),
    ));
    expect(find.text('Belum dikembalikan'), findsOneWidget);
    expect(find.text('Pengambilan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
