part of '../bubble_picker_widget.dart';

/// 칼만 필터를 적용하기 위한 클래스
class _KalmanFilter {
  double q; // 프로세스 잡음 공분산
  double r; // 측정 잡음 공분산
  double p; // 추정 공분산
  double x; // 상태 변수
  double k; // 칼만 이득

  /// 생성자에서 필드를 초기화합니다.
  _KalmanFilter({
    required this.q,
    required this.r,
    required this.p,
    required this.x,
  }) : k = 0.0; // 초기 k 값을 0.0으로 설정

  /// 새로운 측정값을 사용하여 필터를 업데이트하고 상태 변수를 반환합니다.
  double update(double measurement) {
    // 예측 단계
    p = p + q;

    // 업데이트 단계
    k = p / (p + r);
    x = x + k * (measurement - x);
    p = (1 - k) * p;

    return x;
  }
}
