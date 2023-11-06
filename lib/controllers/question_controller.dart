import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:upds_quiz/models/Questions.dart';
import 'package:upds_quiz/screens/score/score_screen.dart';

// We use get package for our state management

class QuestionController extends GetxController
    with SingleGetTickerProviderMixin {
  // Lets animated our progress bar

  late AnimationController _animationController;
  late Animation _animation;
  // so that we can access our animation outside
  Animation get animation => this._animation;

  late PageController _pageController;
  PageController get pageController => this._pageController;

  void resetQuiz() {
    _isAnswered = false;
    _correctAns = 0;
    _selectedAns = -1;
    _questionNumber.value = 1; // Reinicializa el número de pregunta
    _numOfCorrectAns = 0; // Restablece el contador de respuestas correctas
    _questions = getRandomQuestions(sample_data, 4);
    _animationController.reset();
    _pageController = PageController();
    update();
  }

  List<Question> _questions = sample_data
      .map(
        (question) => Question(
            id: question['id'],
            question: question['question'],
            options: question['options'],
            answer: question['answer_index']),
      )
      .toList();
  List<Question> get questions => this._questions;

  bool _isAnswered = false;
  bool get isAnswered => this._isAnswered;

  late int _correctAns;
  int get correctAns => this._correctAns;

  late int _selectedAns;
  int get selectedAns => this._selectedAns;

  // for more about obs please check documentation
  RxInt _questionNumber = 1.obs;
  RxInt get questionNumber => this._questionNumber;

  int _numOfCorrectAns = 0;
  int get numOfCorrectAns => this._numOfCorrectAns;

  @override
  void onInit() {
    final random = Random();
    final selectedQuestions = <Question>[];

    while (selectedQuestions.length < 4) {
      final randomIndex = random.nextInt(sample_data.length);
      final randomQuestionData = sample_data[randomIndex];
      final randomQuestion = Question(
        id: randomQuestionData["id"],
        question: randomQuestionData["question"],
        options: List<String>.from(randomQuestionData["options"]),
        answer: randomQuestionData["answer_index"],
      );

      selectedQuestions.add(randomQuestion);
    }
    _questions = selectedQuestions;

    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        update();
      });

    _animationController.forward().whenComplete(nextQuestion);
    _pageController = PageController();

    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
    _animationController.dispose();
    _pageController.dispose();
  }

  void checkAns(Question question, int selectedIndex) {
    // because once user press any option then it will run
    _isAnswered = true;
    _correctAns = question.answer;
    _selectedAns = selectedIndex;

    if (_correctAns == _selectedAns) _numOfCorrectAns++;

    // It will stop the counter
    _animationController.stop();
    update();

    // Once user select an ans after 3s it will go to the next qn
    Future.delayed(const Duration(seconds: 1), () {
      nextQuestion();
    });
  }

  void nextQuestion() {
    if (_questionNumber.value != _questions.length) {
      _isAnswered = false;
      _pageController.nextPage(
          duration: const Duration(milliseconds: 250), curve: Curves.ease);
      // Reset the counter
      _animationController.reset();

      // Then start it again
      // Once timer is finish go to the next qn
      _animationController.forward().whenComplete(nextQuestion);
    } else {
      // Get package provide us simple way to naviigate another page
      Get.to(ScoreScreen());
    }
  }

  void updateTheQnNum(int index) {
    _questionNumber.value = index + 1;
  }

  List<Question> getRandomQuestions(List<dynamic> data, int count) {
    final random = Random();
    final selectedQuestions = <Question>[];
    final availableIndices = List<int>.generate(data.length, (index) => index);

    while (selectedQuestions.length < count && availableIndices.isNotEmpty) {
      final randomIndex = random.nextInt(availableIndices.length);
      final dataIndex = availableIndices[randomIndex];
      final randomQuestionData = data[dataIndex];
      final randomQuestion = Question(
        id: randomQuestionData["id"],
        question: randomQuestionData["question"],
        options: List<String>.from(randomQuestionData["options"]),
        answer: randomQuestionData["answer_index"],
      );
      selectedQuestions.add(randomQuestion);
      availableIndices.removeAt(randomIndex);
    }
    return selectedQuestions;
  }
}
