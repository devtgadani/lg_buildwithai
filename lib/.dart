import 'package:flutter/material.dart';

class MiniQuiz extends StatefulWidget {
  @override
  _MiniQuizState createState() => _MiniQuizState();
}

class _MiniQuizState extends State<MiniQuiz> {
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _showScore = false;
  bool _optionSelected = false;
  TextEditingController _inputController = TextEditingController();
  bool _isGenerating = false;

  Future<void> _fetchQuizData(String topic) async {
    setState(() {
      _isGenerating = true;
      _questions = [];
      _showScore = false;
      _score = 0;
      _currentQuestionIndex = 0;
    });

    // Simulated Gemini API (replace this with actual API logic)
    await Future.delayed(Duration(seconds: 2)); // Simulate delay

    List<QuizQuestion> fetchedQuestions = _mockGeminiQuiz(topic);

    setState(() {
      _questions = fetchedQuestions;
      _isGenerating = false;
    });
  }

  List<QuizQuestion> _mockGeminiQuiz(String topic) {
    // This is where you’ll later use Gemini to dynamically generate quiz
    return [
      QuizQuestion(
        question: "What is $topic?",
        options: ["a. Concept", "b. Tool", "c. Method", "d. App"],
        correctAnswerIndex: 0,
      ),
      QuizQuestion(
        question: "Which language is associated with $topic?",
        options: ["a. Java", "b. Dart", "c. Python", "d. Kotlin"],
        correctAnswerIndex: 2,
      ),
      QuizQuestion(
        question: "Where can you learn about $topic?",
        options: ["a. YouTube", "b. Library", "c. GitHub", "d. All of the above"],
        correctAnswerIndex: 3,
      ),
    ];
  }

  void _onOptionSelected(int selectedIndex) {
    if (!_showScore && !_optionSelected) {
      setState(() {
        _optionSelected = true;
      });
      if (_questions[_currentQuestionIndex].correctAnswerIndex == selectedIndex) {
        _score++;
      }
    }
  }

  void _nextQuestion() {
    if (_optionSelected) {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _optionSelected = false;
        });
      } else {
        setState(() {
          _showScore = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mini Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _questions.isEmpty
            ? Column(
                children: [
                  TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      labelText: "Enter quiz topic (e.g., Flutter, AI)",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) _fetchQuizData(value.trim());
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      String topic = _inputController.text.trim();
                      if (topic.isNotEmpty) _fetchQuizData(topic);
                    },
                    child: Text("Generate Quiz"),
                  ),
                  if (_isGenerating) ...[
                    SizedBox(height: 20),
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text("Generating quiz on the fly...")
                  ]
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: QuizQuestionCard(
                      question: _questions[_currentQuestionIndex],
                      onOptionSelected: _onOptionSelected,
                      showScore: _showScore,
                      score: _score,
                      optionSelected: _optionSelected,
                    ),
                  ),
                  if (!_showScore && _optionSelected)
                    ElevatedButton(
                      onPressed: _nextQuestion,
                      child: Text('Next'),
                    ),
                ],
              ),
      ),
    );
  }
}
