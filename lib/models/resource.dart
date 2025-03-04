// lib/models/resource.dart
import 'dart:math';

/// Resource 모델은 다양한 자원 유형(식량, 물, 에너지, 미네랄 등)에 대해
/// 각 자원의 현재 양, 최대량, 재생률, 고갈 임계치 등을 관리하며,
/// 환경 효과에 따라 동적으로 자원량이 변화할 수 있도록 설계되었습니다.
class Resource {
  final int id;
  final String type;
  double x;
  double y;
  double quantity;    // 현재 자원량
  double maxQuantity; // 자원이 가질 수 있는 최대량
  double regenRate;   // 초당 재생량
  double depletionThreshold; // 자원이 고갈로 간주되는 임계치

  final Random _rand = Random();

  Resource({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.quantity,
    this.maxQuantity = 100.0,
    this.regenRate = 1.0,
    this.depletionThreshold = 10.0,
  });

  /// dt(초)를 기준으로 재생률에 따라 자원을 회복합니다.
  /// 회복 후 최대량을 초과하지 않도록 보정합니다.
  void regenerate(double dt) {
    quantity += regenRate * dt;
    if (quantity > maxQuantity) {
      quantity = maxQuantity;
    }
  }

  /// 소비 요청량(amount)만큼 자원을 감소시키고, 실제 소비된 양을 반환합니다.
  /// 만약 자원량이 부족하면 현재 남은 양만큼 소비합니다.
  double consume(double amount) {
    double consumed = (amount < quantity) ? amount : quantity;
    quantity -= consumed;
    if (quantity < 0) quantity = 0;
    return consumed;
  }

  /// 환경 효과 적용: multiplier 값을 곱해 자원량에 직접적인 변화를 줍니다.
  /// 예를 들어, multiplier가 0.5이면 자원량이 급감하고, 1.2이면 20% 증가합니다.
  void applyEnvironmentalEffect(double multiplier) {
    quantity *= multiplier;
    if (quantity > maxQuantity) {
      quantity = maxQuantity;
    }
    if (quantity < 0) {
      quantity = 0;
    }
  }

  /// 자원 분포를 동적으로 이동시키는 함수 (예: 자연 재해 후 이동)
  /// dx, dy만큼 좌표를 이동시키고 wrap-around 처리를 합니다.
  void move(double dx, double dy, int areaSize) {
    x += dx;
    y += dy;
    x = x % areaSize;
    if (x < 0) x += areaSize;
    y = y % areaSize;
    if (y < 0) y += areaSize;
  }
}
