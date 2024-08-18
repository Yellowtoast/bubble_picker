part of 'bubble_picker_widget.dart';

class Bubble {
  final void Function(double radius)? onTapBubble;
  final ui.Image? image;
  final ColorFilter? colorFilter;
  final BoxFit? boxFit;
  double dx;
  double dy;
  double radius;
  Color color;
  Offset velocity;
  Offset offsetFromCenter;
  Widget? child;

  Bubble({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.color,
    required this.velocity,
    required this.offsetFromCenter,
    this.child,
    this.onTapBubble,
    this.image,
    this.colorFilter,
    this.boxFit,
  });

  factory Bubble.fromOptions(
    Offset center, {
    Color? color,
    double? radius,
    Widget? child,
    void Function(double radius)? onTapBubble,
    ui.Image? image,
    ColorFilter? colorFilter,
    BoxFit? boxFit,
  }) {
    final random = Random();
    double angle = random.nextDouble() * 2 * pi;
    double distance = random.nextDouble() * 100 + 50;
    Offset offsetFromCenter = Offset(distance * cos(angle), distance * sin(angle));
    return Bubble(
      dx: center.dx + offsetFromCenter.dx,
      dy: center.dy + offsetFromCenter.dy,
      radius: (radius ?? random.nextDouble()) * 20 + 20,
      color: color ?? Color.fromRGBO(random.nextInt(256), random.nextInt(256), random.nextInt(256), 1),
      velocity: Offset(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1),
      offsetFromCenter: offsetFromCenter,
      child: child,
      onTapBubble: onTapBubble,
      image: image,
      colorFilter: colorFilter,
      boxFit: boxFit,
    );
  }

  void update(
    List<Bubble> bubbles,
    Offset clusterCenter,
    Size screenSize,
    double attractionStrength,
    double repulsionStrength,
  ) {
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
