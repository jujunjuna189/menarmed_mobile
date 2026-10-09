import 'package:flutter/material.dart';
import 'package:menarmed_mobile/screens/learning/article/article_screen.dart';
import 'package:menarmed_mobile/screens/learning/bujuk/bujuk_screen.dart';
import 'package:menarmed_mobile/screens/learning/e_learning/e_learning_screen.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({Key? key}) : super(key: key);

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 48),
        child: ColoredBox(
          color: Colors.white,
          child: TabBar(
            controller: _controller,
            indicatorWeight: 3.0,
            indicatorColor: const Color(0xFF252525),
            labelColor: const Color(0xFF252525),
            unselectedLabelColor: const Color(0xFF73777D),
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            dividerColor: const Color(0xFFE2E4E7),
            tabs: const [
              Tab(text: "Artikel"),
              Tab(text: "E-Learning"),
              Tab(text: "Bujuk"),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: const [ArticleScreen(), ELearningScreen(), BujukScreen()],
      ),
    );
  }
}
