import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menarmed_mobile/widgets/popup/popup_permission.dart';

void main() {
  for (final vehicle in [false, true]) {
    testWidgets('Permission vehicle=$vehicle displays appropriate inputs', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => PopupPermission.instance.showPopup(
                  context,
                  vehicle: vehicle,
                  callback: (_) {},
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Tujuan'), findsOneWidget);
      expect(
        find.text('Jenis Kendaraan'),
        vehicle ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
