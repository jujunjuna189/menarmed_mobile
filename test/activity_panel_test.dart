import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menarmed_mobile/widgets/activity_panel.dart';

void main() {
  testWidgets('panel fits narrow screen and scan remains actionable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var scanned = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ActivityPanel(
                title: 'Kembalikan senjata',
                done: true,
                icon: Icons.inventory_2_outlined,
                time: '2026-10-04 08:30:00',
                details: const {
                  'Keterangan': 'Senjata sudah dikembalikan ke gudang',
                },
                onScan: () => scanned = true,
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('08:30:00'), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    expect(scanned, isTrue);
  });
}
