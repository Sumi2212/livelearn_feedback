import 'package:flutter/material.dart';
import 'main_container.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final List<Color> colors = [
    Colors.lightBlueAccent,
    Colors.blueAccent,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('LiveLearn Feedback')),
        body: MainContainer(colors),
      ),
    );
  }
}
