import 'package:bubble_picker/bubble_picker.dart';
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
        body: GradientBubblePicker(),
      ),
    );
  }
}

class GradientBubblePicker extends StatelessWidget {
  const GradientBubblePicker({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> emotions = [
      'Love',
      'Fear',
      'Joy',
      'Hope',
      'Hate',
      'Calm',
    ];

    // List of gradients to be applied to the bubbles
    List<LinearGradient> gradients = [
      const LinearGradient(
        colors: [Color(0xFFFF7E5F), Color.fromARGB(255, 21, 20, 18)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFFF6A88), Color(0xFFFFD194)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];

    return Center(
      child: BubblePicker(
        bubbles: List.generate(emotions.length, (index) {
          return BubbleData(
            gradient: gradients[index],
            child: Text(
              emotions[index],
              style: const TextStyle(color: Colors.white),
            ),
          );
        }),
      ),
    );
  }
}
