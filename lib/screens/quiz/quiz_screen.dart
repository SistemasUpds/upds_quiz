import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:upds_quiz/controllers/question_controller.dart';
import 'package:upds_quiz/screens/quiz/components/body.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    QuestionController _controller = Get.put(QuestionController());
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Body(),
    );
  }
}
