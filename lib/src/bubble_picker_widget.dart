import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

part 'bubble.dart';
part 'bubble_data.dart';
part 'bubble_painter.dart';

class BubblePicker extends StatefulWidget {
  final Size size;
  final List<BubbleData> bubbles;
  const BubblePicker({
    Key? key,
    this.size = const Size(400, 800),
    required this.bubbles,
  }) : super(key: key);

  @override
  State<BubblePicker> createState() => _BubblePickerState();
}

class _BubblePickerState extends State<BubblePicker> with SingleTickerProviderStateMixin {
  late List<Bubble> bubbles;
  late AnimationController _controller;
  Offset clusterCenter = const Offset(200, 400);
  Offset velocity = Offset.zero;
  final double gravity = 0.0;
  final double friction = 0.95; // 속도 감쇠
  final double attractionStrength = 0.009; // 군집 중심으로의 끌어당김 강도
  final double repulsionStrength = 0.5; // 버블 간의 반발 강도

  @override
  void initState() {
    super.initState();

    _initializeBubbles();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..addListener(() {
        setState(() {
          // 군집 중심의 위치를 업데이트
          velocity = Offset(velocity.dx * friction, velocity.dy * friction + gravity);
          clusterCenter += velocity;

          // 모든 버블을 업데이트
          for (var bubble in bubbles) {
            bubble.update(bubbles, clusterCenter, widget.size, attractionStrength, repulsionStrength);
          }
        });
      });
    _controller.repeat();
  }

  Future<void> _initializeBubbles() async {
    bubbles = [];
    for (var bubbleData in widget.bubbles) {
      final image = await loadImage(bubbleData.image);
      bubbles.add(
        Bubble.fromOptions(
          Offset(clusterCenter.dx, clusterCenter.dy),
          image: image,
          color: bubbleData.color,
          radius: bubbleData.radius,
          colorFilter: bubbleData.colorFilter,
          child: bubbleData.child,
        ),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            clusterCenter += details.delta;
            for (var bubble in bubbles) {
              bubble.dx += details.delta.dx;
              bubble.dy += details.delta.dy;
            }
          });
        },
        onTapUp: (details) {
          setState(() {
            final tapPosition = details.localPosition;
            for (var bubble in bubbles) {
              if ((Offset(bubble.dx, bubble.dy) - tapPosition).distance <= bubble.radius) {
                bubble.radius += 5; // 클릭 시 크기 증가
                bubble.onTapBubble?.call(bubble.radius);
                break;
              }
            }
          });
        },
        child: Stack(
          children: [
            CustomPaint(
              size: widget.size,
              painter: _BubblePainter(bubbles),
            ),
            ...bubbles.map((bubble) {
              return Positioned(
                left: bubble.dx - bubble.radius,
                top: bubble.dy - bubble.radius,
                child: SizedBox(
                  width: bubble.radius * 2,
                  height: bubble.radius * 2,
                  child: Center(
                    child: bubble.child,
                  ),
                ),
              );
            }).toList(),
          ],
        ));
  }
}

extension NormalizeOffset on Offset {
  Offset normalize() {
    double length = distance;
    if (length == 0) return this;
    return this / length;
  }
}

Future<ui.Image?> loadImage(ImageProvider? provider) async {
  if (provider == null) return null;
  final completer = Completer<ui.Image>();
  final imageStream = provider.resolve(ImageConfiguration.empty);
  final listener = ImageStreamListener(
    (ImageInfo info, bool synchronousCall) {
      completer.complete(info.image);
    },
    onError: (exception, stackTrace) {
      throw exception;
    },
  );
  imageStream.addListener(listener);
  return completer.future;
}
