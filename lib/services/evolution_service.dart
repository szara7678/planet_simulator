// lib/services/evolution_service.dart
import 'dart:math';
import '../models/advanced_creature.dart';

class EvolutionService {
  /// 현재 자원 수치와 생명체 상태를 기반으로 새로운 고도화 생명체를 생성합니다.
  /// 조건 예시: 자원이 80 이상이고 평균 에너지가 70 이상이면 새 생명체 2마리를 생성합니다.
  static List<AdvancedCreature> checkAndEvolve({
    required double resourceCount,
    required List<AdvancedCreature> creatures,
    required int simulationAreaSize,
    required int nextId,
  }) {
    List<AdvancedCreature> newCreatures = [];
    double avgEnergy = creatures.isNotEmpty
        ? creatures.map((c) => c.energy).reduce((a, b) => a + b) / creatures.length
        : 0;

    if (resourceCount > 80 && avgEnergy > 70) {
      Random random = Random();
      for (int i = 0; i < 2; i++) {
        AdvancedCreature newCreature = AdvancedCreature(
          id: nextId + i,
          x: random.nextDouble() * simulationAreaSize,
          y: random.nextDouble() * simulationAreaSize,
          energy: 120,
        );
        newCreatures.add(newCreature);
      }
    }
    return newCreatures;
  }
}
