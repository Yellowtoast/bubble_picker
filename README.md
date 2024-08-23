
![resized](https://github.com/user-attachments/assets/66aef270-7e12-4452-be69-b210d4c9f3d1)

# Bubble Picker

A customizable and interactive bubble picker widget for Flutter. This widget displays a collection of bubbles that are attracted to a central point while repelling each other. Users can interact with the bubbles by tapping or dragging them around.

## Table of Contents

- [Bubble Picker](#bubble-picker)
  - [Features](#features)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Customization](#customization)
    - [BubbleData properties](#bubbledata-properties)
  - [Contributions](#contributions)
  - [License](#license)

## Features

- **Interactive Bubbles**: Bubbles can be dragged, tapped, and will respond to user interactions.
- **Customizable Appearance**: Customize the color, size, image, and gradient of each bubble.
- **Dynamic Animations**: Bubbles smoothly animate towards a central point and repel each other.
- **Flexible Configuration**: Define bubbles with child widgets, images, and custom behaviors.


## Usage

Import the `BubblePicker` widget into your Dart file:

```dart
  import 'package:bubble_picker/bubble_picker.dart';
```
Create a `BubblePicker` widget:
```dart

BubblePicker(
  size: Size(400, 800),
  bubbles: [
    BubbleData(
      color: Colors.blue,
      radius: 0.1,
      child: Icon(Icons.star, color: Colors.white),
    ),
    BubbleData(
      imageProvider: AssetImage('assets/images/bubble.png'),
      radius: 0.15,
    ),
    // Add more bubbles here
  ],
)

```
## Example

Import the `BubblePicker` widget into your Dart file:

```dart
import 'package:flutter/material.dart';
import 'package:bubble_picker/bubble_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Bubble Picker Example'),
        ),
        body: Center(
          child: BubblePicker(
            size: Size(400, 800),
            bubbles: [
              BubbleData(
                color: Colors.red,
                radius: 0.1,
                child: Text('A'),
              ),
              BubbleData(
                imageProvider: AssetImage('assets/bubble_image.png'),
              ),
              BubbleData(
                imageProvider: AssetImage('assets/bubble_image.png'),
                color: Colors.red.withOpacity(0.3),
                radius: 0.2,
              ),
              BubbleData(
                imageProvider: AssetImage('assets/bubble_image.png'),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF6A88).withOpacity(0.5),
                    const Color(0xFFFFD194).withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              // Add more bubbles here
            ],
          ),
        ),
      ),
    );
  }
}

```
## Customization

### BubbleData Properties

- **`color`**: The background color of the bubble. it will be applied as an overlay on top of the `imageProvider` (if any).
- **`radius`**: The radius of the bubble as a fraction of the widget's height.
- **`child`**: A widget to be displayed at the center of the bubble.
- **`onTapBubble`**: A callback that is triggered when the bubble is tapped.
- **`imageProvider`**: An image to be used as the background of the bubble.
- **`colorFilter`**: A color filter applied to the background image.
- **`boxFit`**: How the background image should be inscribed into the bubble.
- **`gradient`**: A gradient to be used as the background of the bubble. it will be applied as an overlay on top of the `imageProvider` (if any).

## Contributions

Contributions are welcome! If you find any issues or have suggestions, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

