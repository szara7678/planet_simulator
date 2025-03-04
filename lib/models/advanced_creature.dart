// lib/models/advanced_creature.dart
import 'dart:math';
import 'resource.dart';

typedef PredationFunction = bool Function(AdvancedCreature predator, AdvancedCreature target);
typedef ReproductionFunction = AdvancedCreature? Function(AdvancedCreature parent, int nextId, int areaSize);
typedef SocialInteractionFunction = void Function(List<AdvancedCreature> group);
typedef ResourceConsumptionFunction = double Function(AdvancedCreature creature, Resource resource);

/// AdvancedCreature는 동적 유전자 구조와 행동 로직을 사용하여,
/// AI나 돌연변이에 의해 행동 방식 자체도 변경될 수 있는 고도화된 생명체 모델입니다.
class AdvancedCreature {
  final int id;
  double x;
  double y;
  int energy;

  /// 유전자 기반 속성을 동적으로 관리하기 위한 Map.
  /// 'family' 속성은 종족 혹은 가족을 식별합니다.
  /// 'resourcePreference'는 각 자원 유형(예: "식량", "물", "에너지")에 대한 소비 선호도를 나타냅니다.
  Map<String, dynamic> geneProperties;

  final Random _rand = Random();

  AdvancedCreature({
    required this.id,
    required this.x,
    required this.y,
    required this.energy,
    Map<String, dynamic>? geneProperties,
  }) : this.geneProperties = geneProperties ?? {
    'speed': 10.0,
    'reproductionRate': 0.05,
    'consumptionRate': 5.0,
    'predatorStarvationThreshold': 30,
    'targetWeakThreshold': 20,
    'energyDifferenceThreshold': 20,
    'resourceConsumption': 2.0,
    // 추가된 유전자 속성: 면역력, 지능, 감각능력
    'immunity': 0.8,
    'intelligence': 50.0,
    'sensitivity': 30.0,
    // 종족(가족) 속성: 기본값 "Alpha" (나중에 돌연변이나 AI로 변경될 수 있음)
    'family': 'Alpha',
    // 각 자원에 대한 소비 선호도 (예: 식량은 1.0, 물은 0.8, 에너지는 0.5)
    'resourcePreference': {
      '식량': 1.0,
      '물': 0.8,
      '에너지': 0.5,
      '미네랄': 0.7,
    },
  };

  // 게터들
  double get speed => geneProperties['speed'] as double;
  double get reproductionRate => geneProperties['reproductionRate'] as double;
  double get consumptionRate => geneProperties['consumptionRate'] as double;
  int get predatorStarvationThreshold => geneProperties['predatorStarvationThreshold'] as int;
  int get targetWeakThreshold => geneProperties['targetWeakThreshold'] as int;
  int get energyDifferenceThreshold => geneProperties['energyDifferenceThreshold'] as int;
  double get resourceConsumption => geneProperties['resourceConsumption'] as double;
  double get immunity => geneProperties['immunity'] as double;
  double get intelligence => geneProperties['intelligence'] as double;
  double get sensitivity => geneProperties['sensitivity'] as double;
  String get family => geneProperties['family'] as String;

  /// 부드러운 이동 및 에너지 소비 (wrap-around 포함)
  void updateSmooth(double dt, int areaSize) {
    double dx = (_rand.nextDouble() * 2 - 1) * speed * dt;
    double dy = (_rand.nextDouble() * 2 - 1) * speed * dt;
    x += dx;
    y += dy;
    x = x % areaSize;
    if (x < 0) x += areaSize;
    y = y % areaSize;
    if (y < 0) y += areaSize;
    energy = (energy - (consumptionRate * dt)).floor();
    if (energy < 0) energy = 0;
  }

  /// 동적 자원 소비 및 에너지 보충 로직 (향후 AI나 돌연변이에 의해 교체 가능)
  static ResourceConsumptionFunction resourceConsumptionLogic =
      (AdvancedCreature creature, Resource resource) {
    double baseConsumption = creature.resourceConsumption;
    double preference = 1.0;
    if (creature.geneProperties.containsKey('resourcePreference')) {
      Map<String, dynamic> pref = creature.geneProperties['resourcePreference'];
      if (pref.containsKey(resource.type)) {
        preference = pref[resource.type] as double;
      }
    }
    double effectiveConsumption = baseConsumption * preference;
    double preQuantity = resource.quantity;
    double consumed = resource.consume(effectiveConsumption);
    int energyGain;
    if (preQuantity < resource.depletionThreshold) {
      energyGain = (consumed * 2.5).floor();
    } else {
      energyGain = (consumed * 5).floor();
    }
    creature.energy += energyGain;
    return consumed;
  };

  /// 인스턴스 메서드: 자원 소비 호출
  double consumeResource(Resource resource) {
    return resourceConsumptionLogic(this, resource);
  }

  /// 기본 포식 로직 (동적 함수로 분리)
  static PredationFunction predationLogic = (AdvancedCreature predator, AdvancedCreature target) {
    bool canPredate = (target.energy <= (target.geneProperties['targetWeakThreshold'] as int)) ||
        (predator.energy <= (predator.geneProperties['predatorStarvationThreshold'] as int));
    if (!canPredate) {
      return false;
    }
    if (predator.energy > target.energy + (predator.geneProperties['energyDifferenceThreshold'] as int)) {
      predator.energy += (target.energy * 0.5).floor();
      target.energy = 0;
      return true;
    }
    return false;
  };

  bool tryPredate(AdvancedCreature target) {
    return predationLogic(this, target);
  }

  /// 기본 번식 로직 (동적 함수로 분리)
  static ReproductionFunction reproductionLogic = (AdvancedCreature parent, int nextId, int areaSize) {
    if (parent.energy > 150 && parent._rand.nextDouble() < (parent.geneProperties['reproductionRate'] as double)) {
      int childEnergy = (parent.energy * 0.5).floor();
      parent.energy = (parent.energy * 0.8).floor();
      Map<String, dynamic> childGenes = Map.from(parent.geneProperties);
      childGenes.forEach((key, value) {
        if (value is double) {
          childGenes[key] = value + value * (parent._rand.nextDouble() * 0.2 - 0.1);
        } else if (value is int) {
          childGenes[key] = value + (parent._rand.nextInt(5) - 2);
        }
      });
      // 자식은 부모의 종족을 기본적으로 상속, 돌연변이로 변경될 가능성 있음
      if (parent._rand.nextDouble() < 0.05) { // 5% 확률로 종족 변경
        childGenes['family'] = ['Alpha', 'Beta', 'Gamma'][parent._rand.nextInt(3)];
      }
      if (parent._rand.nextDouble() < 0.1) {
        childGenes['newGene'] = parent._rand.nextDouble() * 10;
      }
      if (parent._rand.nextDouble() < 0.05 && childGenes.isNotEmpty) {
        List<String> keys = childGenes.keys.toList();
        childGenes.remove(keys[parent._rand.nextInt(keys.length)]);
      }
      return AdvancedCreature(
        id: nextId,
        x: parent.x,
        y: parent.y,
        energy: childEnergy,
        geneProperties: childGenes,
      );
    }
    return null;
  };

  AdvancedCreature? tryReproduce(int nextId, int areaSize) {
    return reproductionLogic(this, nextId, areaSize);
  }

  /// 사회적 상호작용 함수: 그룹 내 협력이나 집단 행동 (예: 평균 지능이 높으면 에너지 보충)
  static SocialInteractionFunction socialInteractionLogic = (List<AdvancedCreature> group) {
    if (group.isEmpty) return;
    double avgIntelligence = group.map((c) => c.intelligence).reduce((a, b) => a + b) / group.length;
    if (avgIntelligence > 60) {
      for (var creature in group) {
        creature.energy += 5;
      }
    }
  };

  void interactWithGroup(List<AdvancedCreature> group) {
    socialInteractionLogic(group);
  }

  /// 동적 유전자 수정 메서드들
  void updateGeneProperty(String key, dynamic value) {
    geneProperties[key] = value;
  }

  void removeGeneProperty(String key) {
    geneProperties.remove(key);
  }

  void addGeneProperty(String key, dynamic value) {
    if (!geneProperties.containsKey(key)) {
      geneProperties[key] = value;
    }
  }
}
