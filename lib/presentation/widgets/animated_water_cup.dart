import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedWaterCup extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double width;
  final double height;

  const AnimatedWaterCup({
    super.key,
    required this.progress,
    this.width = 60,
    this.height = 80,
  });

  @override
  State<AnimatedWaterCup> createState() => _AnimatedWaterCupState();
}

class _AnimatedWaterCupState extends State<AnimatedWaterCup>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.progress >= 1.0
              ? Colors.cyanAccent
              : Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          if (widget.progress >= 1.0)
            BoxShadow(
              color: Colors.cyanAccent.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 1,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Wave Custom Painter
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.width, widget.height),
                  painter: _WaterWavePainter(
                    progress: widget.progress,
                    waveValue: _waveController.value,
                  ),
                );
              },
            ),

            // Percentage Text Overlay
            Text(
              '${(widget.progress.clamp(0.0, 1.0) * 100).toInt()}%',
              style: TextStyle(
                color: widget.progress > 0.45 ? Colors.white : Colors.cyanAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                shadows: const [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterWavePainter extends CustomPainter {
  final double progress;
  final double waveValue;

  _WaterWavePainter({
    required this.progress,
    required this.waveValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillHeight = size.height * progress.clamp(0.0, 1.0);
    final baseWaterY = size.height - fillHeight;

    if (progress <= 0.001) return;

    // Wave path calculation
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, baseWaterY);

    const waveCount = 1.2;
    final waveAmplitude = progress >= 1.0 ? 2.0 : 4.0;

    for (double x = 0; x <= size.width; x++) {
      final y = baseWaterY +
          math.sin((x / size.width * waveCount * 2 * math.pi) + (waveValue * 2 * math.pi)) *
              waveAmplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    // Water Gradient Fill
    final waterGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.cyanAccent.withValues(alpha: 0.9),
        Colors.blue.shade600,
        Colors.deepPurple.shade900,
      ],
    );

    final paint = Paint()
      ..shader = waterGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Wave Crest Line Highlight
    final crestPath = Path();
    crestPath.moveTo(0, baseWaterY);
    for (double x = 0; x <= size.width; x++) {
      final y = baseWaterY +
          math.sin((x / size.width * waveCount * 2 * math.pi) + (waveValue * 2 * math.pi)) *
              waveAmplitude;
      crestPath.lineTo(x, y);
    }

    final crestPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(crestPath, crestPaint);
  }

  @override
  bool shouldRepaint(covariant _WaterWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.waveValue != waveValue;
  }
}
