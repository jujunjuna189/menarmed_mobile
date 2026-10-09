import 'package:flutter/material.dart';
import 'package:menarmed_mobile/repository/e_learning_repo.dart';
import 'package:menarmed_mobile/widgets/learning_list.dart';

class ELearningScreen extends StatelessWidget {
  const ELearningScreen({super.key});

  @override
  Widget build(BuildContext context) => LearningList(
    load: () => ELearningRepo.instance.show({}),
    label: 'E-Learning',
    route: '/e_learning_view',
    icon: Icons.school_outlined,
    article: false,
  );
}
