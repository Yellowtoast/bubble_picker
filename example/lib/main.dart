import 'package:example/gradient_bubble_picker.dart';
import 'package:example/image_bubble_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: IndexedStack(
          index: 0,
          children: [
            GradientBubblePicker(),
            ImageBubblePicker(),
          ],
        ),
      ),
    );
  }
}
