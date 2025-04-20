import 'package:flutter/material.dart';
import 'package:mini/quiz_question.dart';
import 'geminidev.dart';
import 'dart:convert';

class MiniQuiz extends StatefulWidget {
  @override
  _MiniQuizState createState() => _MiniQuizState();
}

class _MiniQuizState extends State<MiniQuiz> {
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  final GeminiI gsd = GeminiI();
  bool _showScore = false;
  bool _optionSelected = false;
  TextEditingController _inputController = TextEditingController();
  bool _isGenerating = false;
  final TextEditingController _numQuestionsController = TextEditingController();

  String cleanMarkdownJson(String response) {
    if (response.startsWith("```")) {
      final startIndex = response.indexOf('\n') + 1;
      final endIndex = response.lastIndexOf('```');
      return response.substring(startIndex, endIndex).trim();
    }
    return response.trim();
  }

  Future<void> _fetchQuizData(String topic, int numQuestions) async {
    setState(() {
      _isGenerating = true;
      _questions = [];
      _showScore = false;
      _score = 0;
      _currentQuestionIndex = 0;
    });

    try {
      final quizList = await gsd.generateContent(
        query: topic,
        topic: "mini",
        numberOfQuestions: numQuestions,
      );

      List<QuizQuestion> fetchedQuestions = quizList.map<QuizQuestion>((item) {
        return QuizQuestion(
          question: item['question'],
          options: List<String>.from(item['options']),
          correctAnswerIndex: item['correctAnswerIndex'],
        );
      }).toList();

      setState(() {
        _questions = fetchedQuestions;
        _isGenerating = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to generate quiz. Please try again.")),
      );
    }
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

    void _restartQuiz() {
    setState(() {
      // Reset quiz state
      _currentQuestionIndex = 0;
      _score = 0;
      _showScore = false;
      _optionSelected = false;
    });
  }

  void _createNewQuiz() {
    setState(() {
      _questions = [];
      _inputController.clear();
      _numQuestionsController.clear();
      _showScore = false;
      _score = 0;
      _currentQuestionIndex = 0;
      _optionSelected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
  appBar: null, 
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _questions.isEmpty
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        labelText: "Enter quiz topic (e.g., Liquid Galaxy, AI)",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.quiz, color: Colors.blueGrey),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Number of Questions",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.format_list_numbered, color: Colors.blueGrey),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                      controller: _numQuestionsController,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        String topic = _inputController.text.trim();
                        String countStr = _numQuestionsController.text.trim();
                        int? count = int.tryParse(countStr);

                        if (topic.isEmpty || countStr.isEmpty || count == null || count <= 0) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text("Missing Input"),
                              content: Text("Please enter a valid topic and number of questions."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: Text("OK"),
                                )
                              ],
                            ),
                          );
                          return;
                        }

                        _fetchQuizData(topic, count);
                      },
                      icon: Icon(Icons.play_arrow),
                      label: Text("Generate Quiz",
                      style: TextStyle(color: Colors.white, fontSize: 16),),
                      style: ElevatedButton.styleFrom(
                        
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 16),
                        backgroundColor: Colors.blueAccent, // button color
                      ),
                    ),
                    if (_isGenerating) ...[
                      SizedBox(height: 20),
                      Center(child: CircularProgressIndicator()),
                      SizedBox(height: 8),
                      Text(
                        "Generating quiz on the fly...",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700]),
                      )
                    ]
                  ],
                ),
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
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        textStyle: TextStyle(fontSize: 16),
                        backgroundColor: Colors.blueAccent, // button color
                      ),
                    ),
                  if (_showScore)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        "Your Score: $_score / ${_questions.length}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                     SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _restartQuiz,
                      icon: Icon(Icons.replay),
                      label: Text("Restart Quiz",
                      style: TextStyle(color: Colors.white, fontSize: 16),),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        textStyle: TextStyle(fontSize: 16),
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _createNewQuiz,
                      icon: Icon(Icons.create_new_folder),
                      label: Text("Create New Quiz"),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        textStyle: TextStyle(fontSize: 16),
                        side: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  
                ],
              ),
                
              ),
      
    );
  }
}
