import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/flashcard_data.dart';
import '../models/flashcard.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/glass_container.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  late List<Flashcard> _cards;
  int _currentIndex = 0;
  bool _isFlipped = false;
  String _selectedCategory = 'Semua';

  // Map card id -> bool (true = benar, false = salah)
  final Map<String, bool> _answers = {};

  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    _cards = List.from(defaultFlashcards);
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    super.dispose();
  }

  void _filterCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'Semua') {
        _cards = List.from(defaultFlashcards);
      } else {
        _cards = defaultFlashcards.where((c) => c.category == category).toList();
      }
      _currentIndex = 0;
      _isFlipped = false;
    });
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _nextCard() {
    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    } else {
      _showResultDialog();
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
    }
  }

  void _handleScore(bool isCorrect) {
    final currentCard = _cards[_currentIndex];
    setState(() {
      _answers[currentCard.id] = isCorrect;
    });

    // Otomatis lanjut ke kartu berikutnya setelah jeda singkat
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      if (_currentIndex < _cards.length - 1) {
        _nextCard();
      } else {
        _showResultDialog();
      }
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _isFlipped = false;
      _answers.clear();
      _cards.shuffle();
    });
  }

  int get _correctCount => _answers.values.where((v) => v == true).length;
  int get _wrongCount => _answers.values.where((v) => v == false).length;
  int get _answeredCount => _answers.length;

  void _showResultDialog() {
    final total = _cards.length;
    final correct = _correctCount;
    final percentage = total > 0 ? ((correct / total) * 100).round() : 0;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) {
        return Center(
          child: SingleChildScrollView(
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: GlassContainer(
                width: 380,
                blur: 24,
                opacity: 0.22,
                borderRadius: BorderRadius.circular(32),
                customGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.3),
                    Colors.purple.shade900.withValues(alpha: 0.4),
                    Colors.indigo.shade900.withValues(alpha: 0.5),
                  ],
                ),
                borderColor: Colors.white,
                borderOpacity: 0.35,
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge Icon
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade400, Colors.pink.shade500],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.emoji_events_rounded, size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      'Kuis Selesai! 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Hasil Evaluasi Flashcard Anda',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                    ),
                    const SizedBox(height: 22),

                    // Score Big Circle
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$percentage%',
                            style: const TextStyle(
                              color: Color(0xFF69F0AE),
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            percentage >= 75 ? 'Predikat: Sangat Memuaskan! 🌟' : 'Terus Berlatih & Tingkatkan! 💪',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats Breakdown
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF69F0AE), size: 22),
                                const SizedBox(height: 4),
                                Text(
                                  '$correct Benar',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 22),
                                const SizedBox(height: 4),
                                Text(
                                  '$_wrongCount Salah',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                            ),
                            child: const Text('Tutup', style: TextStyle(color: Colors.white70)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _restartQuiz();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.25),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 1.2),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh_rounded, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Ulangi Kuis',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = _cards.isNotEmpty ? _cards[_currentIndex] : null;
    final total = _cards.length;
    final progress = total > 0 ? (_currentIndex + 1) / total : 0.0;
    final categories = ['Semua', 'Flutter Basics', 'Dart Language', 'UI & Design', 'Flutter Layout', 'Flutter State'];

    return Scaffold(
      backgroundColor: const Color(0xFF3B2EFA), // Vibrant Blue like reference
      body: Stack(
        children: [
          // Glowing animated ambient background loops (abstract 3D-like shapes)
          AnimatedBuilder(
            animation: _bgAnimationController,
            builder: (context, child) {
              final val = _bgAnimationController.value;
              return Stack(
                children: [
                  // Top left magenta loop
                  Positioned(
                    top: -120 + (30 * math.sin(val * math.pi)),
                    left: -80 + (20 * math.cos(val * math.pi)),
                    child: Transform.rotate(
                      angle: val * math.pi * 0.1,
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFF1E82).withValues(alpha: 0.85),
                            width: 70,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF1E82).withValues(alpha: 0.5),
                              blurRadius: 100,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom right cyan/blue loop
                  Positioned(
                    bottom: -150 + (25 * math.cos(val * math.pi)),
                    right: -100 + (30 * math.sin(val * math.pi)),
                    child: Transform.rotate(
                      angle: -val * math.pi * 0.15,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.7),
                            width: 60,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
                              blurRadius: 120,
                              spreadRadius: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Extra deep blue/purple glow center-right
                  Positioned(
                    top: 250 + (20 * math.sin(val * math.pi)),
                    right: -50,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF7C4DFF).withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Main Screen Content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Glass Card (Inspired by reference "Good Day, Mark!")
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    borderRadius: BorderRadius.circular(24),
                    child: Row(
                      children: [
                        // User Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8A65), Color(0xFFFF4081)],
                            ),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pinkAccent.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'NZ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title & Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      'Halo, Naila Aribah Zahra',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.95),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text('✨', style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Flashcard Quiz',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Shuffle / Reset Button
                        Tooltip(
                          message: 'Kocok / Ulangi Kuis',
                          child: GlassContainer(
                            padding: const EdgeInsets.all(10),
                            borderRadius: BorderRadius.circular(16),
                            onTap: _restartQuiz,
                            child: const Icon(Icons.shuffle_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Dashboard Metrics Cards (Mirip Steps 1265 & Calories 413 pada Glassmorphism UI referensi)
                  Row(
                    children: [
                      // Metric 1: Benar
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          borderRadius: BorderRadius.circular(18),
                          customGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF00E676).withValues(alpha: 0.22),
                              Colors.white.withValues(alpha: 0.08),
                            ],
                          ),
                          borderColor: const Color(0xFF69F0AE),
                          borderOpacity: 0.35,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Benar',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF69F0AE), size: 16),
                                ],
                              ),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '$_correctCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      ' / $total',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Metric 2: Salah
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          borderRadius: BorderRadius.circular(18),
                          customGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.redAccent.withValues(alpha: 0.20),
                              Colors.white.withValues(alpha: 0.08),
                            ],
                          ),
                          borderColor: Colors.redAccent,
                          borderOpacity: 0.35,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Salah',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 16),
                                ],
                              ),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '$_wrongCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      ' kartu',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Metric 3: Terjawab
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          borderRadius: BorderRadius.circular(18),
                          customGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.amber.withValues(alpha: 0.20),
                              Colors.white.withValues(alpha: 0.08),
                            ],
                          ),
                          borderColor: const Color(0xFFFFD54F),
                          borderOpacity: 0.35,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Dijawab',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.bolt_rounded, color: Color(0xFFFFD54F), size: 16),
                                ],
                              ),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '$_answeredCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      ' / $total',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Kategori Filter Pills
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = cat == _selectedCategory;
                        return GestureDetector(
                          onTap: () => _filterCategory(cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.28)
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : Colors.white.withValues(alpha: 0.18),
                                width: isSelected ? 1.4 : 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Progress Bar Indikator
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kemajuan Kuis',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Kartu ${_currentIndex + 1} dari $total',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            Container(
                              height: 7,
                              width: double.infinity,
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                            FractionallySizedBox(
                              widthFactor: progress.clamp(0.0, 1.0),
                              child: Container(
                                height: 7,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF), Color(0xFFFF4081)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // The Flashcard itself
                  if (currentCard != null)
                    FlashcardWidget(
                      flashcard: currentCard,
                      currentIndex: _currentIndex,
                      totalCards: total,
                      isAnsweredCorrectly: _answers[currentCard.id],
                      onFlip: _flipCard,
                      isFlipped: _isFlipped,
                      onScore: _handleScore,
                    )
                  else
                    const Center(
                      child: Text('Tidak ada kartu untuk kategori ini.', style: TextStyle(color: Colors.white)),
                    ),

                  const SizedBox(height: 18),

                  // Bottom Navigation & Controls (Previous, Flip, Next)
                  Row(
                    children: [
                      // Tombol Previous
                      Expanded(
                        flex: 3,
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          borderRadius: BorderRadius.circular(18),
                          onTap: _currentIndex > 0 ? _previousCard : null,
                          opacity: _currentIndex > 0 ? 0.16 : 0.05,
                          borderColor: _currentIndex > 0 ? Colors.white : Colors.white24,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 14,
                                  color: _currentIndex > 0 ? Colors.white : Colors.white30,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Kembali',
                                  style: TextStyle(
                                    color: _currentIndex > 0 ? Colors.white : Colors.white30,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Tombol Flip Utama
                      Expanded(
                        flex: 4,
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          borderRadius: BorderRadius.circular(20),
                          onTap: _flipCard,
                          customGradient: LinearGradient(
                            colors: [
                              Colors.deepPurpleAccent.withValues(alpha: 0.4),
                              Colors.pinkAccent.withValues(alpha: 0.3),
                            ],
                          ),
                          borderColor: Colors.white.withValues(alpha: 0.6),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.flip_rounded, color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  _isFlipped ? 'Pertanyaan' : 'Lihat Jawaban',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Tombol Next
                      Expanded(
                        flex: 3,
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          borderRadius: BorderRadius.circular(18),
                          onTap: _nextCard,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentIndex < total - 1 ? 'Lanjut' : 'Selesai',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  _currentIndex < total - 1
                                      ? Icons.arrow_forward_ios_rounded
                                      : Icons.check_circle_outline_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);
}
}
