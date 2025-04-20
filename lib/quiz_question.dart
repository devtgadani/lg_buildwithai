import 'package:flutter/material.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class QuizQuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final Function(int) onOptionSelected;
  final bool showScore;
  final int score;
  final bool optionSelected;

  QuizQuestionCard({
    required this.question,
    required this.onOptionSelected,
    required this.showScore,
    required this.score,
    required this.optionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question text
            Text(
              question.question,
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            SizedBox(height: 30),
            
            // Answer options
            Column(
              children: question.options.asMap().entries.map((entry) {
                int index = entry.key;
                String option = entry.value;

                // Button style logic
                Color buttonColor = Colors.white;
                Color textColor = Colors.black87;
                Color borderColor = Colors.grey.shade300;
                Widget? trailingIcon;

                if (optionSelected) {
                  if (index == question.correctAnswerIndex) {
                    buttonColor = Colors.purple.shade100;
                    textColor = Colors.purple;
                    borderColor = Colors.purple;
                    trailingIcon = Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purple,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    );
                  }
                }

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (!optionSelected) {
                          onOptionSelected(index);
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (trailingIcon != null) trailingIcon,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            // Score display (if needed)
           
          ],
        ),
      ),
    );
  }
}