part of 'bubble_picker_widget.dart';

/// The [_Bubble] class represents a single bubble within the [BubblePicker] widget.
/// Each bubble has properties such as position, size, color, velocity, and can interact with other bubbles.
class _Bubble {
  /// Callback triggered when the bubble is tapped. Receives the updated radius.
  final void Function(double radius)? onTapBubble;

  /// The image to be displayed inside the bubble, if any.
  final ui.Image? image;

  /// Optional color filter applied to the image inside the bubble.
  final ColorFilter? colorFilter;

  /// Defines how the image should be fit inside the bubble.
  final BoxFit? boxFit;

  /// X-coordinate of the bubble's position.
  double dx;

  /// Y-coordinate of the bubble's position.
  double dy;

  /// Radius of the bubble.
  double radius;

  /// Background color of the bubble.
  Color color;

  /// The current velocity of the bubble, influencing its movement.
  Offset velocity;

  /// The offset from the cluster center where the bubble originated.
  Offset offsetFromCenter;

  /// Optional widget to be displayed inside the bubble (e.g., an icon or text).
  Widget? child;

  /// Constructor for creating a [_Bubble] instance.
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
  });

  /// Factory method to create a [_Bubble] instance with randomized initial properties.
  ///
  /// [center]: The initial center of the cluster of bubbles.
  /// [color]: The background color of the bubble.
  /// [radius]: The initial radius of the bubble. If not provided, a random value is used.
  /// [child]: An optional widget to display inside the bubble.
  /// [onTapBubble]: Callback to trigger when the bubble is tapped.
  /// [image]: An optional image to display as the background of the bubble.
  /// [colorFilter]: An optional color filter for the image.
  /// [boxFit]: Specifies how the image should be fit inside the bubble.
  factory _Bubble.fromOptions(
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
    return _Bubble(
      dx: center.dx + offsetFromCenter.dx,
      dy: center.dy + offsetFromCenter.dy,
      radius: (radius ?? random.nextDouble()) * 20 + 20, // Randomize the radius if not provided
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

  /// Updates the position and velocity of the bubble based on its interactions with other bubbles
  /// and the cluster center.
  ///
  /// [bubbles]: List of all bubbles in the picker.
  /// [clusterCenter]: The current center point of the bubble cluster.
  /// [screenSize]: The size of the screen or widget where the bubbles are displayed.
  /// [attractionStrength]: The strength of the force pulling the bubble towards the cluster center.
  /// [repulsionStrength]: The strength of the force pushing the bubbles away from each other.
  void update(
    List<_Bubble> bubbles,
    Offset clusterCenter,
    Size screenSize,
    double attractionStrength,
    double repulsionStrength,
  ) {
    // Apply attraction force towards the cluster center
    Offset attraction = (clusterCenter - Offset(dx, dy)) * attractionStrength;
    velocity += attraction;

    // Apply damping to the velocity to reduce its magnitude over time
    velocity = Offset(velocity.dx * 0.98, velocity.dy * 0.98); // Adjust damping

    // Calculate new position based on velocity
    dx += velocity.dx;
    dy += velocity.dy;

    for (var bubble in bubbles) {
      if (bubble == this) continue; // Skip self in the interaction loop

      double distance = (Offset(dx, dy) - Offset(bubble.dx, bubble.dy)).distance;
      double minDistance = radius + bubble.radius;

      if (distance < minDistance) {
        // Apply soft repulsion force to avoid overlapping
        double overlap = minDistance - distance;
        Offset direction = (Offset(dx, dy) - Offset(bubble.dx, bubble.dy)).normalize();
        Offset repulsion = direction * overlap * repulsionStrength;

        // Adjust positions based on the repulsion force
        dx += repulsion.dx;
        dy += repulsion.dy;
        bubble.dx -= repulsion.dx;
        bubble.dy -= repulsion.dy;

        // Adjust velocities after collision for bounce effect
        velocity = Offset(velocity.dx * 0.8, velocity.dy * 0.8);
        bubble.velocity = Offset(bubble.velocity.dx * 0.8, bubble.velocity.dy * 0.8);
      }
    }

    // Apply boundary constraints to ensure bubbles stay within screen bounds
    if (dx - radius < 0) {
      dx = radius;
      velocity = Offset(-velocity.dx * 0.8, velocity.dy); // Reflect velocity at the boundary
    } else if (dx + radius > screenSize.width) {
      dx = screenSize.width - radius;
      velocity = Offset(-velocity.dx * 0.8, velocity.dy); // Reflect velocity at the boundary
    }

    if (dy - radius < 0) {
      dy = radius;
      velocity = Offset(velocity.dx, -velocity.dy * 0.8); // Reflect velocity at the boundary
    } else if (dy + radius > screenSize.height) {
      dy = screenSize.height - radius;
      velocity = Offset(velocity.dx, -velocity.dy * 0.8); // Reflect velocity at the boundary
    }
  }
}
