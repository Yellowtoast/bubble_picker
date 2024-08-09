import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BubblePicker extends StatefulWidget {
  const BubblePicker({super.key});

  @override
  _BubblePickerState createState() => _BubblePickerState();
}

class _BubblePickerState extends State<BubblePicker> with SingleTickerProviderStateMixin {
  late List<Bubble> bubbles;
  late AnimationController _controller;
  Offset clusterCenter = const Offset(200, 400);
  Offset velocity = Offset.zero;
  final double gravity = 0.0;
  final double friction = 0.95; // 속도 감쇠
  final double attractionStrength = 0.01; // 군집 중심으로의 끌어당김 강도
  final double repulsionStrength = 0.4; // 버블 간의 반발 강도

  @override
  void initState() {
    super.initState();
    bubbles = List.generate(15, (index) => Bubble.random(clusterCenter));
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
            bubble.update(bubbles, clusterCenter, context.size!, attractionStrength, repulsionStrength);
          }
        });
      });
    _controller.repeat();
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
          // 사용자의 제스처에 따라 군집 중심과 모든 버블을 이동
          clusterCenter += details.delta;
          for (var bubble in bubbles) {
            bubble.dx += details.delta.dx;
            bubble.dy += details.delta.dy;
          }
        });
      },
      onTapUp: (details) {
        setState(() {
          // 클릭된 위치에 있는 버블을 찾고 크기를 증가시킴
          final tapPosition = details.localPosition;
          for (var bubble in bubbles) {
            if ((Offset(bubble.dx, bubble.dy) - tapPosition).distance <= bubble.radius) {
              bubble.radius += 5; // 클릭 시 크기 증가
              break;
            }
          }
        });
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return CustomPaint(
            painter: BubblePainter(bubbles),
            child: Container(),
          );
        },
      ),
    );
  }
}

class Bubble {
  double dx;
  double dy;
  double radius;
  Color color;
  Offset velocity;
  Offset offsetFromCenter;

  Bubble({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.color,
    required this.velocity,
    required this.offsetFromCenter,
  });

  factory Bubble.random(Offset center) {
    final random = Random();
    double angle = random.nextDouble() * 2 * pi;
    double distance = random.nextDouble() * 100 + 50;
    Offset offsetFromCenter = Offset(distance * cos(angle), distance * sin(angle));
    return Bubble(
      dx: center.dx + offsetFromCenter.dx,
      dy: center.dy + offsetFromCenter.dy,
      radius: random.nextDouble() * 20 + 20,
      color: Color.fromRGBO(random.nextInt(256), random.nextInt(256), random.nextInt(256), 1),
      velocity: Offset(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1),
      offsetFromCenter: offsetFromCenter,
    );
  }

  void update(List<Bubble> bubbles, Offset clusterCenter, Size screenSize, double attractionStrength,
      double repulsionStrength) {
    // 중심점을 향한 끌어당김 (attraction force)
    Offset attraction = (clusterCenter - Offset(dx, dy)) * attractionStrength;
    velocity += attraction;

    // 속도에 감쇠를 적용
    velocity = Offset(velocity.dx * 0.98, velocity.dy * 0.98); // 감쇠 조정

    // 새로운 위치 계산
    dx += velocity.dx;
    dy += velocity.dy;

    for (var bubble in bubbles) {
      if (bubble == this) continue;
      double distance = (Offset(dx, dy) - Offset(bubble.dx, bubble.dy)).distance;
      double minDistance = radius + bubble.radius;

      if (distance < minDistance) {
        // 중첩 방지 및 부드러운 반발력 적용
        double overlap = minDistance - distance;
        Offset direction = (Offset(dx, dy) - Offset(bubble.dx, bubble.dy)).normalize();
        Offset repulsion = direction * overlap * repulsionStrength;

        // 반발력을 적용하여 버블 위치 조정
        dx += repulsion.dx;
        dy += repulsion.dy;
        bubble.dx -= repulsion.dx;
        bubble.dy -= repulsion.dy;

        // 충돌 후 반발 효과로 속도 조정
        velocity = Offset(velocity.dx * 0.8, velocity.dy * 0.8);
        bubble.velocity = Offset(bubble.velocity.dx * 0.8, bubble.velocity.dy * 0.8);
      }
    }

    // 화면 경계에서 반발 효과 적용
    if (dx - radius < 0) {
      dx = radius;
      velocity = Offset(-velocity.dx * 0.8, velocity.dy);
    } else if (dx + radius > screenSize.width) {
      dx = screenSize.width - radius;
      velocity = Offset(-velocity.dx * 0.8, velocity.dy);
    }

    if (dy - radius < 0) {
      dy = radius;
      velocity = Offset(velocity.dx, -velocity.dy * 0.8);
    } else if (dy + radius > screenSize.height) {
      dy = screenSize.height - radius;
      velocity = Offset(velocity.dx, -velocity.dy * 0.8);
    }
  }
}

extension NormalizeOffset on Offset {
  Offset normalize() {
    double length = distance;
    if (length == 0) return this;
    return this / length;
  }
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;

  BubblePainter(this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var bubble in bubbles) {
      paint.color = bubble.color;
      canvas.drawCircle(Offset(bubble.dx, bubble.dy), bubble.radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
