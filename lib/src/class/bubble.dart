part of '../bubble_picker_widget.dart';

/// [_Bubble] represents a single bubble within the [BubblePicker] widget.
/// It encapsulates properties such as position, size, color, and image, and
/// handles the update logic for movement and interaction with other bubbles,
/// incorporating a Kalman filter for more accurate position estimation.
class _Bubble {
  /// A callback triggered when the bubble is tapped.
  /// It passes the current radius of the bubble to the callback function.
  final void Function(double radius)? onTapBubble;

  /// The image to be displayed inside the bubble, if provided.
  /// This image is drawn using the specified [boxFit] and [colorFilter].
  final ui.Image? image;

  /// An optional color filter to apply to the [image].
  /// This can be used to apply effects such as tinting the image.
  final ColorFilter? colorFilter;

  /// The fit strategy to use when drawing the [image] inside the bubble.
  /// Defaults to [BoxFit.cover] if not specified, ensuring the image covers the entire bubble.
  final BoxFit? boxFit;

  /// An optional gradient to be used as the background of the bubble.
  /// If provided, this gradient will be drawn in place of the [color] or [image].
  final Gradient? gradient;

  /// X-coordinate position of the bubble on the screen.
  double dx;

  /// Y-coordinate position of the bubble on the screen.
  double dy;

  /// The radius of the bubble, which controls its size.
  double radius;

  /// The background color of the bubble.
  /// This color is used if no [image] or [gradient] is provided.
  Color color;

  /// The current velocity of the bubble, used for animating movement.
  Offset velocity;

  /// The offset from the cluster center where the bubble originated.
  Offset offsetFromCenter;

  /// An optional widget to be displayed inside the bubble, such as text or an icon.
  Widget? child;

  /// Kalman filter for smoothing the x-coordinate of the bubble's position.
  final _KalmanFilter kfX;

  /// Kalman filter for smoothing the y-coordinate of the bubble's position.
  final _KalmanFilter kfY;

  /// Constructs a [_Bubble] object with the specified properties and initializes Kalman filters.
  ///
  /// The [dx], [dy], [radius], [color], [velocity], and [offsetFromCenter] parameters are required.
  /// The [child], [onTapBubble], [image], [colorFilter], [boxFit], and [gradient] parameters are optional.
  _Bubble({
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
    this.gradient,
  })  : kfX = _KalmanFilter(q: 1, r: 1, p: 1, x: dx),
        kfY = _KalmanFilter(q: 1, r: 1, p: 1, x: dy);

  /// Creates a [_Bubble] object with random initial properties based on the given [center].
  ///
  /// The [center] determines the initial position of the bubble. Optional parameters allow
  /// for customization of the bubble's appearance, such as [color], [radius], [child], [image],
  /// [colorFilter], [boxFit], and [gradient]. If not provided, random values are used.
  factory _Bubble.fromOptions(
    Offset center, {
    Color? color,
    double? radius,
    Widget? child,
    void Function(double radius)? onTapBubble,
    ui.Image? image,
    ColorFilter? colorFilter,
    BoxFit? boxFit,
    Gradient? gradient,
  }) {
    final random = Random();
    double angle = random.nextDouble() * 2 * pi;
    double distance = random.nextDouble() * 100 + 50;
    Offset offsetFromCenter = Offset(distance * cos(angle), distance * sin(angle));
    return _Bubble(
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
      gradient: gradient,
    );
  }

  /// Updates the bubble's position and velocity based on attraction to the cluster center,
  /// repulsion from other bubbles, and collisions with screen boundaries.
  ///
  /// This version uses Kalman filters to predict the new position for smoother motion.
  /// The [bubbles] list contains all bubbles in the cluster, [clusterCenter] is the central point
  /// of the cluster, and [screenSize] defines the size of the screen for boundary detection.
  /// The [attractionStrength] controls the force pulling bubbles towards the center,
  /// while [repulsionStrength] controls the force pushing bubbles away from each other.
  void update(
    List<_Bubble> bubbles,
    Offset clusterCenter,
    Size screenSize,
    double attractionStrength,
    double repulsionStrength,
  ) {
    // Calculate the attraction force towards the cluster center.
    Offset attraction = (clusterCenter - Offset(dx, dy)) * attractionStrength;
    velocity += attraction;

    // Apply damping to slow down the velocity over time.
    velocity = Offset(velocity.dx * 0.98, velocity.dy * 0.98);

    // Predict the new position using Kalman filter.
    double predictedDx = kfX.update(dx + velocity.dx);
    double predictedDy = kfY.update(dy + velocity.dy);

    dx = predictedDx;
    dy = predictedDy;

    for (var bubble in bubbles) {
      if (bubble == this) continue; // Skip self to avoid self-collision.
      double distance = (Offset(dx, dy) - Offset(bubble.dx, bubble.dy)).distance;
      double minDistance = radius + bubble.radius;

      if (distance < minDistance) {
        // Calculate overlap and apply repulsion force to avoid overlapping.
        double overlap = minDistance - distance;
        Offset direction = (Offset(dx, dy) - Offset(bubble.dx, bubble.dy)).normalize();
        Offset repulsion = direction * overlap * repulsionStrength;

        // Adjust positions to resolve the overlap.
        dx += repulsion.dx;
        dy += repulsion.dy;
        bubble.dx -= repulsion.dx;
        bubble.dy -= repulsion.dy;

        // Apply damping to simulate collision energy loss.
        velocity = Offset(velocity.dx * 0.8, velocity.dy * 0.8);
        bubble.velocity = Offset(bubble.velocity.dx * 0.8, bubble.velocity.dy * 0.8);
      }
    }

    // Handle collisions with screen boundaries by bouncing the bubble back.
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
