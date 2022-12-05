import 'package:flutter/material.dart';
import 'package:flutter_animated_circle_progress/circle_progress_bar.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Animated Circle Progress"),
      ),
      body: const Center(
        child: ProgressCard(),
      ),
    );
  }
}

class ProgressCard extends StatefulWidget {
  const ProgressCard({super.key});
  @override
  ProgressCardState createState() => ProgressCardState();
}

class ProgressCardState extends State<ProgressCard> {
  double progressPercent = 0.2;

  @override
  Widget build(BuildContext context) {
    Color foreground = Colors.red;

    if (progressPercent >= 0.8) {
      foreground = Colors.green;
    } else if (progressPercent >= 0.4) {
      foreground = Colors.orange;
    } else if (progressPercent >= 0.2) {
      foreground = Colors.blue;
    }

    Color background = foreground.withOpacity(0.2);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: CircleProgressBar(
                backgroundColor: background,
                foregroundColor: foreground,
                value: progressPercent,
              ),
              onTap: () {
                final updated = ((progressPercent + 0.1).clamp(0.0, 1.0) * 100);
                setState(() {
                  progressPercent = updated.round() / 100;
                });
              },
              onDoubleTap: () {
                final updated = ((progressPercent - 0.1).clamp(0.0, 1.0) * 100);
                setState(() {
                  progressPercent = updated.round() / 100;
                });
              },
            ),
          ),
        ),
        Text("${progressPercent * 100}%"),
      ],
    );
  }
}
