part of 'bubble_picker_widget.dart';

class _BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;

  _BubblePainter(this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var bubble in bubbles) {
      // 캔버스 상태 저장
      canvas.save();

      // 동그라미 클립 경로 설정
      Path clipPath = Path()..addOval(Rect.fromCircle(center: Offset(bubble.dx, bubble.dy), radius: bubble.radius));
      canvas.clipPath(clipPath);

      if (bubble.image != null) {
        // 이미지 배경을 그리기
        paintImage(
          canvas: canvas,
          rect: Rect.fromCircle(center: Offset(bubble.dx, bubble.dy), radius: bubble.radius),
          image: bubble.image!,
          fit: bubble.boxFit ?? BoxFit.cover,
          colorFilter: bubble.colorFilter,
        );
      } else {
        // 컬러 배경을 그리기
        paint.color = bubble.color;
        canvas.drawCircle(
          Offset(bubble.dx, bubble.dy),
          bubble.radius,
          paint,
        );
      }

      // 캔버스 상태 복원
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
