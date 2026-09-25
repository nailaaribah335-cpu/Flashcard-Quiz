import 'package:flutter/material.dart';
import 'screens/quiz_screen.dart';

void main() {
  runApp(const FlashcardQuizApp());
}

class FlashcardQuizApp extends StatelessWidget {
  const FlashcardQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Quiz - Naila Aribah Zahra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF130B29),
        primaryColor: const Color(0xFF7C4DFF),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF7C4DFF),
          secondary: const Color(0xFF00E5FF),
          surface: Colors.white.withValues(alpha: 0.1),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const QuizScreen(),
    );
  }
}
