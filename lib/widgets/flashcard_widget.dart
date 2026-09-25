import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import 'glass_container.dart';

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;
  final int currentIndex;
  final int totalCards;
  final bool? isAnsweredCorrectly; // null: belum dijawab, true: benar, false: salah
  final VoidCallback onFlip;
  final bool isFlipped;
  final Function(bool isCorrect) onScore;

  const FlashcardWidget({
    super.key,
    required this.flashcard,
    required this.currentIndex,
    required this.totalCards,
    required this.isAnsweredCorrectly,
    required this.onFlip,
    required this.isFlipped,
    required this.onScore,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool _showHint = false;

  @override
  void didUpdateWidget(covariant FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flashcard.id != widget.flashcard.id) {
      _showHint = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onFlip,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          final rotate = Tween(begin: math.pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              final isUnder = (ValueKey(widget.isFlipped) != child?.key);
              var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.002;
              tilt *= isUnder ? -1.0 : 1.0;
              final value = isUnder ? math.min(rotate.value, math.pi / 2) : rotate.value;
              return Transform(
                transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        child: widget.isFlipped ? _buildBackSide() : _buildFrontSide(),
      ),
    );
  }

  Widget _buildFrontSide() {
    return GlassContainer(
      key: const ValueKey(false),
      width: double.infinity,
      height: 440,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      customGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.10),
          Colors.deepPurple.shade900.withValues(alpha: 0.20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.school_rounded, color: Color(0xFFFFD54F), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      widget.flashcard.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Text(
                  '${widget.currentIndex + 1} / ${widget.totalCards}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Pertanyaan
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.flashcard.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Petunjuk (Hint) section
          if (_showHint) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.shade900.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.shade300.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_rounded, color: Color(0xFFFFD54F), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.flashcard.hint,
                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showHint = true;
                  });
                },
                icon: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFFFD54F), size: 16),
                label: const Text(
                  'Lihat Petunjuk',
                  style: TextStyle(color: Color(0xFFFFD54F), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Flip helper footer
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app_rounded, color: Colors.white.withValues(alpha: 0.7), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Ketuk kartu untuk melihat jawaban',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.flip_camera_android_rounded, color: Colors.white.withValues(alpha: 0.7), size: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackSide() {
    return GlassContainer(
      key: const ValueKey(true),
      width: double.infinity,
      height: 440,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      customGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.24),
          Colors.cyan.shade900.withValues(alpha: 0.25),
          Colors.deepPurple.shade900.withValues(alpha: 0.35),
        ],
      ),
      borderColor: const Color(0xFF64FFDA),
      borderOpacity: 0.35,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Jawaban
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.5), width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: Color(0xFF69F0AE), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Kunci Jawaban',
                      style: TextStyle(
                        color: Color(0xFFB9F6CA),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.flip_to_front_rounded, color: Colors.white70, size: 20),
                tooltip: 'Kembali ke pertanyaan',
                onPressed: widget.onFlip,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Area Jawaban yang di-scroll jika panjang
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.flashcard.answer,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: Color(0xFF80D8FF), size: 15),
                            SizedBox(width: 6),
                            Text(
                              'Penjelasan:',
                              style: TextStyle(
                                color: Color(0xFF80D8FF),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.flashcard.explanation,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Pertanyaan Evaluasi Diri & Tombol Penilaian Skor
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Text(
                  'Apakah jawaban Anda benar?',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Tombol Salah
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onScore(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: (widget.isAnsweredCorrectly == false)
                                ? Colors.redAccent.withValues(alpha: 0.5)
                                : Colors.redAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: (widget.isAnsweredCorrectly == false)
                                  ? Colors.redAccent
                                  : Colors.redAccent.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close_rounded, color: Colors.redAccent, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Salah',
                                style: TextStyle(
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
                    const SizedBox(width: 10),
                    // Tombol Benar
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onScore(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: (widget.isAnsweredCorrectly == true)
                                ? const Color(0xFF00E676).withValues(alpha: 0.5)
                                : const Color(0xFF00E676).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: (widget.isAnsweredCorrectly == true)
                                  ? const Color(0xFF00E676)
                                  : const Color(0xFF00E676).withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded, color: Color(0xFF69F0AE), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Benar',
                                style: TextStyle(
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
