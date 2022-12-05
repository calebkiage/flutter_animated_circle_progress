import 'package:flutter/material.dart';
import 'package:flutter_animated_circle_progress/circle_progress_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const transparent = Color(0x00000000);

  testWidgets('Circle progress creates widget with default values',
      (WidgetTester tester) async {
    const fgColor = Color(0xFF000000);
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CircleProgressBar(
      foregroundColor: fgColor,
      value: 0.2,
    ));

    final circleFinder = find.byType(CircleProgressBar);
    final state = tester.state<CircleProgressBarState>(circleFinder);
    final w = tester.element(circleFinder).widget as CircleProgressBar;

    expect(w.animationDuration, const Duration(milliseconds: 600));
    expect(w.backgroundColor, transparent);
    expect(w.foregroundColor, fgColor);
    expect(w.value, 0.2);

    // State test
    expect(circleFinder, findsOneWidget);

    expect(state.backgroundColorTween.begin, transparent);
    expect(state.backgroundColorTween.end, transparent);

    expect(state.foregroundColorTween.begin, fgColor);
    expect(state.foregroundColorTween.end, fgColor);

    expect(state.valueTween.begin, 0.0);
    expect(state.valueTween.end, 0.2);
  });

  testWidgets('Circle progress animates value', (WidgetTester tester) async {
    const fgColor = Color(0xFF000000);
    await tester.pumpWidget(const CircleProgressBar(
      foregroundColor: Color(0xFF000000),
      value: 0.2,
    ));
    final circleFinder = find.byType(CircleProgressBar);
    final state = tester.state<CircleProgressBarState>(circleFinder);
    expect(circleFinder, findsOneWidget);

    // Animate
    await tester.pump(const Duration(milliseconds: 600));
    expect(state.foregroundColorTween.evaluate(state.curve), fgColor);
    expect(state.valueTween.evaluate(state.curve), 0.2);
  });
}
