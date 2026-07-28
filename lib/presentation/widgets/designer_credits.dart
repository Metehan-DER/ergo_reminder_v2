import 'package:flutter/material.dart';

class DesignerCredits extends StatelessWidget {
  final String designerName;
  final String animationPath;
  final Duration showDuration;
  final Duration animationDuration;

  const DesignerCredits({
    super.key,
    required this.designerName,
    this.animationPath = '',
    this.showDuration = const Duration(seconds: 3),
    this.animationDuration = const Duration(seconds: 1),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Crafted with",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.favorite,
                size: 14,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 4),
              const Text(
                "by ",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.deepPurpleAccent, Colors.pinkAccent],
                ).createShader(bounds),
                child: Text(
                  designerName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
