import 'package:flutter/widgets.dart';

/// Draws a circular animated progress bar.
class LineProgressBar extends StatefulWidget {
  final Duration animationDuration;
  final Color? backgroundColor;
  final Color foregroundColor;
  final double value;
  final double strokeWidth;

  const LineProgressBar(
      {Key? key,
      this.animationDuration = const Duration(seconds: 1),
      this.backgroundColor,
      required this.foregroundColor,
      required this.value,
      this.strokeWidth = 6})
      : super(key: key);

  @override
  LineProgressBarState createState() {
    return LineProgressBarState();
  }
}

class LineProgressBarState extends State<LineProgressBar>
    with SingleTickerProviderStateMixin {
  // Used in tweens where a backgroundColor isn't given.
  static const TRANSPARENT = Color(0x00000000);
  late AnimationController _controller;

  late Animation<double> curve;
  late Tween<double> valueTween;
  Tween<Color>? backgroundColorTween;
  Tween<Color>? foregroundColorTween;

  @override
  void initState() {
    super.initState();

    this._controller = AnimationController(
      duration: this.widget.animationDuration,
      vsync: this,
    );

    this.curve = CurvedAnimation(
      parent: this._controller,
      curve: Curves.easeInOut,
    );

    // Build the initial required tweens.
    this.valueTween = Tween<double>(
      begin: 0,
      end: this.widget.value,
    );

    this._controller.forward();
  }

  @override
  void didUpdateWidget(LineProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (this.widget.value != oldWidget.value) {
      // Try to start with the previous tween's end value. This ensures that we
      // have a smooth transition from where the previous animation reached.
      double beginValue = this.valueTween.evaluate(this.curve);

      // Update the value tween.
      this.valueTween = Tween<double>(
        begin: beginValue,
        end: this.widget.value,
      );

      // Clear cached color tweens when the color hasn't changed.
      if (oldWidget.backgroundColor != this.widget.backgroundColor) {
        this.backgroundColorTween = Tween(
          begin: oldWidget.backgroundColor,
          end: this.widget.backgroundColor,
        );
      } else {
        this.backgroundColorTween = null;
      }

      if (oldWidget.foregroundColor != this.widget.foregroundColor) {
        this.foregroundColorTween = Tween(
          begin: oldWidget.foregroundColor,
          end: this.widget.foregroundColor,
        );
      } else {
        this.foregroundColorTween = null;
      }

      this._controller
        ..value = 0
        ..forward();
    }
  }

  @override
  void dispose() {
    this._controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: this.curve,
      child: Container(),
      builder: (context, child) {
        final backgroundColor =
            this.backgroundColorTween?.evaluate(this.curve) ??
                this.widget.backgroundColor;
        final foregroundColor =
            this.foregroundColorTween?.evaluate(this.curve) ??
                this.widget.foregroundColor;

        return CustomPaint(
          child: child,
          foregroundPainter: LineProgressBarPainter(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              percentage: this.valueTween.evaluate(this.curve),
              strokeWidth: widget.strokeWidth),
        );
      },
    );
  }
}

// Draws the progress bar.
class LineProgressBarPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color foregroundColor;

  LineProgressBarPainter({
    this.backgroundColor,
    required this.foregroundColor,
    required this.percentage,
    this.strokeWidth = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Size constrainedSize =
        Size(size.width - this.strokeWidth, size.height - strokeWidth);
    final foregroundPaint = Paint()
      ..color = this.foregroundColor
      ..strokeWidth = this.strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Offset start = center - Offset(constrainedSize.width / 2, 0);
    // Don't draw the background if we don't have a background color
    if (this.backgroundColor != null) {
      final backgroundPaint = Paint()
        ..color = this.backgroundColor!
        ..strokeWidth = this.strokeWidth
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
          start, start + Offset(constrainedSize.width, 0), backgroundPaint);
    }

    double length = this.percentage * constrainedSize.width;

    canvas.drawLine(start, start + Offset(length, 0), foregroundPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final oldPainter = (oldDelegate as LineProgressBarPainter);
    return oldPainter.percentage != this.percentage ||
        oldPainter.backgroundColor != this.backgroundColor ||
        oldPainter.foregroundColor != this.foregroundColor ||
        oldPainter.strokeWidth != this.strokeWidth;
  }
}
