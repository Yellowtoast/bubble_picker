part of 'bubble_picker_widget.dart';

class BubbleData {
  const BubbleData({
    this.color,
    this.radius,
    this.child,
    this.onTapBubble,
    this.image,
    this.colorFilter,
    this.boxFit,
  }) : assert(
          radius == null || (radius > 0 && radius < 1),
          'Radius must be greater than 0 and less than 1 if provided',
        );

  final Color? color;
  final double? radius;
  final Widget? child;
  final void Function(double radius)? onTapBubble;
  final ImageProvider? image;
  final ColorFilter? colorFilter;
  final BoxFit? boxFit;
}
