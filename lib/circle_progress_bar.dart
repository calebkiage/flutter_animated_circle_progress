import 'dart:math' as math;

import 'package:flutter/widgets.dart';

// ignore: constant_identifier_names
const TRANSPARENT = Color(0x00000000);

/// Draws a circular animated progress bar.
class CircleProgressBar extends StatefulWidget {
  final Duration animationDuration;
  final Color backgroundColor;
  final Color foregroundColor;
  final double value;

  const CircleProgressBar({
    super.key,
    this.animationDuration = const Duration(milliseconds: 600),
    this.backgroundColor = TRANSPARENT,
    required this.foregroundColor,
    required this.value,
  });

  @override
  CircleProgressBarState createState() {
    return CircleProgressBarState();
  }
}

class CircleProgressBarState extends State<CircleProgressBar>
    with SingleTickerProviderStateMixin {
  // Used in tweens where a backgroundColor isn't given.
  late AnimationController _controller;

  late Animation<double> curve;
  Tween<double> valueTween = Tween<double>(
    begin: 0,
    end: 0,
  );
  late Tween<Color?> backgroundColorTween;
  late Tween<Color?> foregroundColorTween;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Build the initial required tweens.
    valueTween.end = widget.value;

    backgroundColorTween =
        ColorTween(begin: widget.backgroundColor, end: widget.backgroundColor);
    foregroundColorTween =
        ColorTween(begin: widget.foregroundColor, end: widget.foregroundColor);

    _controller.forward();
  }

  @override
  void didUpdateWidget(CircleProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      // Try to start with the previous tween's end value. This ensures that we
      // have a smooth transition from where the previous animation reached.
      double beginValue = _controller.isCompleted
          ? oldWidget.value
          : valueTween.evaluate(curve);

      // Update the value tween.
      valueTween.begin = beginValue;
      valueTween.end = widget.value;

      backgroundColorTween.begin = _controller.isCompleted
          ? oldWidget.backgroundColor
          : backgroundColorTween.evaluate(curve);

      // Preserve color end when it hasn't changed
      if (backgroundColorTween.end != widget.backgroundColor) {
        backgroundColorTween.end = widget.backgroundColor;
      }

      foregroundColorTween.begin = _controller.isCompleted
          ? oldWidget.foregroundColor
          : foregroundColorTween.evaluate(curve);

      if (foregroundColorTween.end != widget.foregroundColor) {
        foregroundColorTween.end = widget.foregroundColor;
      }

      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: AnimatedBuilder(
        animation: curve,
        child: const SizedBox(),
        builder: (context, child) {
          final backgroundColor =
              backgroundColorTween.evaluate(curve) ?? widget.backgroundColor;
          final foregroundColor =
              foregroundColorTween.evaluate(curve) ?? widget.foregroundColor;

          return CustomPaint(
            foregroundPainter: CircleProgressBarPainter(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              percentage: valueTween.evaluate(curve),
            ),
            child: child,
          );
        },
      ),
    );
  }
}

// Draws the progress bar.
class CircleProgressBarPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color backgroundColor;
  final Color foregroundColor;

  CircleProgressBarPainter({
    this.backgroundColor = TRANSPARENT,
    this.strokeWidth = 6,
    required this.foregroundColor,
    this.percentage = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Size constrainedSize =
        (size - Offset(strokeWidth, strokeWidth)) as Size;
    final shortestSide =
        math.min(constrainedSize.width, constrainedSize.height);
    final foregroundPaint = Paint()
      ..color = foregroundColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final radius = (shortestSide / 2);

    // Start at the top. 0 radians represents the right edge
    const double startAngle = -(2 * math.pi * 0.25);
    final double sweepAngle = (2 * math.pi * percentage);

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, backgroundPaint);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final oldPainter = (oldDelegate as CircleProgressBarPainter);
    return oldPainter.percentage != percentage ||
        oldPainter.backgroundColor != backgroundColor ||
        oldPainter.foregroundColor != foregroundColor ||
        oldPainter.strokeWidth != strokeWidth;
  }
}
