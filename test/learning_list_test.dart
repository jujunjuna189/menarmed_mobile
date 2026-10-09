import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menarmed_mobile/widgets/learning_list.dart';

void main() {
  testWidgets('Empty learning data ends loading', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: LearningList(
      load: () async => [], label: 'Bujuk', route: '/bujuk_view', icon: Icons.menu_book_outlined,
    ))));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada bujuk'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Tapping description opens the article with its id', (tester) async {
    Object? arguments;
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: (settings) {
        arguments = settings.arguments;
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Detail artikel')));
      },
      home: Scaffold(body: LearningList(
        load: () async => [{'id': 42, 'judul': 'Materi latihan', 'deskripsi': 'Ringkasan materi'}],
        label: 'Artikel', route: '/article_view', icon: Icons.article_outlined, article: true,
      )),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ringkasan materi'));
    await tester.pumpAndSettle();
    expect(arguments, '{"article_id":42}');
    expect(find.text('Detail artikel'), findsOneWidget);
  });
}
