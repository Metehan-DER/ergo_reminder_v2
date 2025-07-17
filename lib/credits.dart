import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DesignerCredits extends StatefulWidget {
  final String designerName;
  final String animationPath;
  final Duration showDuration;
  final Duration animationDuration;

  const DesignerCredits({
    Key? key,
    required this.designerName,
    this.animationPath = 'assets/animations/fire.json',
    this.showDuration = const Duration(seconds: 3),
    this.animationDuration = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  State<DesignerCredits> createState() => _DesignerCreditsState();
}

class _DesignerCreditsState extends State<DesignerCredits>
    with SingleTickerProviderStateMixin {
  bool _showEasterEgg = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(begin: Colors.black54, end: Colors.orangeAccent),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(begin: Colors.orangeAccent, end: Colors.redAccent),
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _toggleEasterEgg() {
    setState(() {
      _showEasterEgg = true;
    });

    _controller.forward().then((_) {
      Future.delayed(widget.showDuration, () {
        if (mounted) {
          _controller.reverse().then((_) {
            setState(() {
              _showEasterEgg = false;
            });
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Visibility(
              visible: _showEasterEgg,
              child: SizedBox(
                width: 50,
                height: 75,
                child: Lottie.asset(widget.animationPath, fit: BoxFit.contain),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: InkWell(
                onTap: _toggleEasterEgg,
                borderRadius: BorderRadius.circular(70),
                splashColor: Colors.white.withOpacity(0.3),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(70),
                    border: Border.all(
                      color: _colorAnimation.value ?? Colors.black54,
                      width: 1.0 + (_glowAnimation.value * 1.0),
                    ),
                    gradient: _showEasterEgg
                        ? LinearGradient(
                            colors: [
                              Colors.orange.withOpacity(
                                0.3 * _glowAnimation.value,
                              ),
                              Colors.red.withOpacity(
                                0.3 * _glowAnimation.value,
                              ),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    boxShadow: _showEasterEgg
                        ? [
                            BoxShadow(
                              color: Colors.orange.withOpacity(
                                0.3 * _glowAnimation.value,
                              ),
                              blurRadius: 10 * _glowAnimation.value,
                              spreadRadius: 2 * _glowAnimation.value,
                            ),
                            BoxShadow(
                              color: Colors.red.withOpacity(
                                0.3 * _glowAnimation.value,
                              ),
                              blurRadius: 10 * _glowAnimation.value,
                              spreadRadius: 2 * _glowAnimation.value,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    "Designed by ${widget.designerName}",
                    style: TextStyle(
                      color: _colorAnimation.value,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      shadows: _showEasterEgg
                          ? [
                              Shadow(
                                color: Colors.orangeAccent.withOpacity(
                                  0.5 * _glowAnimation.value,
                                ),
                                blurRadius: 8 * _glowAnimation.value,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
