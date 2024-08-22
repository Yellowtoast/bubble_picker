import 'dart:io';

import 'package:bubble_picker/bubble_picker.dart';
import 'package:flutter/material.dart';

class ImageBubblePicker extends StatelessWidget {
  const ImageBubblePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BubblePicker(
        bubbles: List.generate(12, (index) {
          return BubbleData(
            imageProvider: FileImage(File('assets/image1.jpeg')),
            child: Text(
              index.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          );
        }),
      ),
    );
  }
}
