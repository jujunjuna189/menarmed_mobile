import 'package:flutter/material.dart';
import 'package:menarmed_mobile/repository/article_repo.dart';
import 'package:menarmed_mobile/widgets/learning_list.dart';

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key});

  @override
  Widget build(BuildContext context) => LearningList(
    load: () => ArticleRepo.instance.show({}),
    label: 'Artikel',
    route: '/article_view',
    icon: Icons.article_outlined,
    article: true,
  );
}
