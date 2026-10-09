import 'package:flutter/material.dart';
import 'package:menarmed_mobile/repository/bujuk_repo.dart';
import 'package:menarmed_mobile/widgets/learning_list.dart';

class BujukScreen extends StatelessWidget {
  const BujukScreen({super.key});

  @override
  Widget build(BuildContext context) => LearningList(
    load: () => BujukRepo.instance.show({}),
    label: 'Bujuk',
    route: '/bujuk_view',
    icon: Icons.menu_book_outlined,
    article: false,
  );
}
