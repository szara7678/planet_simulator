// lib/screens/advanced_simulation_screen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/advanced_creature.dart';
import '../models/resource.dart';
import '../painters/simulation_painter.dart';
import '../services/database_service.dart';
import '../services/evolution_service.dart';
import '../services/environment_service.dart';
import '../services/code_modification_service.dart';
import '../widgets/modals.dart';

class AdvancedSimulationScreen extends StatefulWidget {
  @override
  _AdvancedSimulationScreenState createState() => _AdvancedSimulationScreenState();
}

class ResourceData {
  final int time;
  final int resource;
  ResourceData(this.time, this.resource);
}

class _AdvancedSimulationScreenState extends State<AdvancedSimulationScreen>
    with SingleTickerProviderStateMixin {
  // 공통 행성 자원은 제거하고, 자원은 각각 Resource 객체로 관리
  List<String> historyLog = [];
  List<String> conversationHistory = [];
  List<AdvancedCreature> creatures = [];
  List<Resource> resources = [];
  // 맵 크기를 600으로 확장하여 전체 화면을 꽉 채우도록 함
  final int simulationAreaSize = 600;
  final Random random = Random();

  int updateCount = 0;
  List<ResourceData> resourceHistory = [];

  late Ticker _ticker;
  Duration _previousTick = Duration.zero;
  Timer? _saveTimer;
  Timer? _evolutionTimer;
  int nextCreatureId = 10;
  int nextResourceId = 0;

  final EnvironmentService environmentService = EnvironmentService(seasonDurationSeconds: 30);
  final CodeModificationService codeModificationService = CodeModificationService();

  @override
  void initState() {
    super.initState();
    // 초기 고도화 생명체 생성 (예: 10마리, 가족은 무작위 지정)
    List<String> families = ['Alpha', 'Beta', 'Gamma'];
    for (int i = 0; i < 10; i++) {
      creatures.add(
        AdvancedCreature(
          id: i,
          x: random.nextDouble() * simulationAreaSize,
          y: random.nextDouble() * simulationAreaSize,
          energy: 100,
          geneProperties: {
            'speed': 10.0,
            'reproductionRate': 0.05,
            'consumptionRate': 5.0,
            'predatorStarvationThreshold': 30,
            'targetWeakThreshold': 20,
            'energyDifferenceThreshold': 20,
            'resourceConsumption': 2.0,
            'immunity': 0.8,
            'intelligence': 50.0,
            'sensitivity': 30.0,
            'family': families[random.nextInt(families.length)],
            'resourcePreference': {
              '식량': 1.0,
              '물': 0.8,
              '에너지': 0.5,
              '미네랄': 0.7,
            },
          },
        ),
      );
    }
    // 초기 자원 생성: 8개, 자원 유형을 무작위로 선택하여 다양한 특성 적용
    List<String> resourceTypes = ['식량', '물', '에너지', '미네랄'];
    for (int i = 0; i < 8; i++) {
      String type = resourceTypes[random.nextInt(resourceTypes.length)];
      double maxQ = 100.0;
      double regen = 1.0;
      double depletion = 10.0;
      if (type == '물') {
        maxQ = 120.0;
        regen = 1.2;
      } else if (type == '에너지') {
        maxQ = 80.0;
        regen = 0.8;
      } else if (type == '미네랄') {
        maxQ = 70.0;
        regen = 0.5;
      }
      resources.add(
        Resource(
          id: nextResourceId++,
          type: type,
          x: random.nextDouble() * simulationAreaSize,
          y: random.nextDouble() * simulationAreaSize,
          quantity: random.nextDouble() * maxQ,
          maxQuantity: maxQ,
          regenRate: regen,
          depletionThreshold: depletion,
        ),
      );
    }
    _ticker = createTicker(_onTick);
    _ticker.start();
    _saveTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _saveSimulationState();
    });
    _evolutionTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _checkEvolution();
    });
  }

  void _onTick(Duration elapsed) {
    if (_previousTick == Duration.zero) {
      _previousTick = elapsed;
      return;
    }
    final dt = (elapsed - _previousTick).inMilliseconds / 1000.0;
    _previousTick = elapsed;
    updateSimulation(dt);
  }

  void updateSimulation(double dt) {
    setState(() {
      updateCount++;

      // 생명체 업데이트 및 자원 소비 처리
      for (AdvancedCreature creature in creatures) {
        creature.updateSmooth(dt * environmentService.energyConsumptionMultiplier, simulationAreaSize);
        // 인접 자원 소비 처리: 각 생명체가 10픽셀 이내의 자원을 소비
        for (Resource resource in resources) {
          double dx = creature.x - resource.x;
          double dy = creature.y - resource.y;
          double distance = sqrt(dx * dx + dy * dy);
          if (distance < 10) {
            double consumed = creature.consumeResource(resource);
            if (consumed > 0) {
              historyLog.add("생명체 ${creature.id} (${creature.family})이 ${resource.type} 소비: ${consumed.toStringAsFixed(1)}, 에너지: ${creature.energy}");
            }
          }
        }
        historyLog.add("생명체 ${creature.id} (${creature.family}) 위치: (${creature.x.toStringAsFixed(1)}, ${creature.y.toStringAsFixed(1)}) 에너지: ${creature.energy}");
      }

      // 자원 재생 (환경 배수를 적용)
      for (Resource resource in resources) {
        resource.regenerate(dt * environmentService.resourceRegenMultiplier);
      }

      // 자원 히스토리 업데이트: 매 업데이트마다 전체 자원 평균 수치를 기록
      resourceHistory.add(ResourceData(updateCount, _calculateAverageResource()));
      if (resourceHistory.length > 100) {
        resourceHistory.removeAt(0);
      }

      if (historyLog.length > 100) {
        historyLog.removeAt(0);
      }
    });
  }

  /// 각 자원들의 평균 자원량 계산
  int _calculateAverageResource() {
    if (resources.isEmpty) return 0;
    double total = resources.map((r) => r.quantity).reduce((a, b) => a + b);
    return (total / resources.length).floor();
  }

  Future<void> _saveSimulationState() async {
    List<Map<String, dynamic>> creaturesData = creatures.map((creature) {
      return {
        'id': creature.id,
        'x': creature.x,
        'y': creature.y,
        'energy': creature.energy,
        'family': creature.family,
      };
    }).toList();
    String creaturesState = jsonEncode(creaturesData);
    await DatabaseService().insertSimulationState(_calculateAverageResource().toDouble(), creaturesState);
    setState(() {
      historyLog.add("상태 저장됨");
    });
  }

  void _checkEvolution() {
    List<AdvancedCreature> newCreatures = EvolutionService.checkAndEvolve(
      resourceCount: _calculateAverageResource().toDouble(),
      creatures: creatures,
      simulationAreaSize: simulationAreaSize,
      nextId: nextCreatureId,
    );
    if (newCreatures.isNotEmpty) {
      setState(() {
        creatures.addAll(newCreatures);
        historyLog.add("새로운 생명체 종 진화: ${newCreatures.map((c) => c.id).toList()}");
        nextCreatureId += newCreatures.length;
      });
    }
  }

  // 보고서용 콜백 함수들
  Map<String, String> _getCreatureGroupReport() {
    Map<String, List<AdvancedCreature>> groups = {};
    for (var creature in creatures) {
      String fam = creature.family;
      if (!groups.containsKey(fam)) {
        groups[fam] = [];
      }
      groups[fam]!.add(creature);
    }
    Map<String, String> report = {};
    groups.forEach((family, list) {
      int count = list.length;
      double avgEnergy = list.map((c) => c.energy).reduce((a, b) => a + b) / count;
      report[family] = "개체 수: $count, 평균 에너지: ${avgEnergy.toStringAsFixed(1)}";
    });
    return report;
  }

  Map<String, String> _getResourceGroupReport() {
    Map<String, List<Resource>> groups = {};
    for (var resource in resources) {
      String type = resource.type;
      if (!groups.containsKey(type)) {
        groups[type] = [];
      }
      groups[type]!.add(resource);
    }
    Map<String, String> report = {};
    groups.forEach((type, list) {
      int count = list.length;
      double avgQuantity = list.map((r) => r.quantity).reduce((a, b) => a + b) / count;
      report[type] = "개수: $count, 평균 수량: ${avgQuantity.toStringAsFixed(1)}";
    });
    return report;
  }

  // 그룹별 역사 기록: 사용자 명령과 시스템 로그를 그룹화
  List<String> _getGroupedHistoryLog() {
    List<String> userCommands = historyLog.where((log) => log.startsWith("사용자 명령:")).toList();
    List<String> systemLogs = historyLog.where((log) => !log.startsWith("사용자 명령:")).toList();
    List<String> grouped = [];
    grouped.add("사용자 명령:");
    grouped.addAll(userCommands);
    grouped.add("시스템 로그:");
    grouped.addAll(systemLogs);
    return grouped;
  }

  void _handleUserCommand(String command) {
    if (command.toLowerCase().contains("날씨 변경")) {
      setState(() {
        historyLog.add("사용자 명령 처리: 날씨 변경 요청 (예: 겨울 적용)");
      });
    } else if (command.toLowerCase().contains("자원 추가")) {
      setState(() {
        historyLog.add("사용자 명령 처리: 자원 추가 요청");
        resources.add(Resource(
          id: nextResourceId++,
          type: "식량",
          x: random.nextDouble() * simulationAreaSize,
          y: random.nextDouble() * simulationAreaSize,
          quantity: 50.0,
          maxQuantity: 100.0,
          regenRate: 1.0,
          depletionThreshold: 10.0,
        ));
      });
    } else if (command.toLowerCase().contains("코드 수정")) {
      String result = codeModificationService.processCommand(command);
      setState(() {
        historyLog.add("코드 수정 결과: $result");
      });
    } else {
      setState(() {
        historyLog.add("알 수 없는 명령: $command");
      });
    }
  }

  void showChatModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ChatModal(
        onSend: (command) {
          setState(() {
            historyLog.add("사용자 명령: $command");
            conversationHistory.add("사용자: $command");
          });
          _handleUserCommand(command);
        },
        conversationHistory: conversationHistory,
      ),
    );
  }

  void showReportModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ReportModal(
        getCurrentSeason: () => environmentService.currentSeason.toString().split('.').last,
        getCreatureGroupReport: _getCreatureGroupReport,
        getResourceGroupReport: _getResourceGroupReport,
      ),
    );
  }

  void showHistoryModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => HistoryModal(
        getHistoryLogGroup: _getGroupedHistoryLog,
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _saveTimer?.cancel();
    _evolutionTimer?.cancel();
    environmentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 전체 화면에 맵을 꽉 채우도록 함
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: CustomPaint(
              painter: SimulationPainter(creatures: creatures, resources: resources),
            ),
          ),
          // 상단 오른쪽에 보고 및 역사 버튼을 배치 (메인 화면에는 계절 정보 표시하지 않음)
          Positioned(
            top: 40,
            right: 16,
            child: Column(
              children: [
                IconButton(
                  icon: Icon(Icons.report, color: Colors.white),
                  onPressed: showReportModal,
                ),
                IconButton(
                  icon: Icon(Icons.history, color: Colors.white),
                  onPressed: showHistoryModal,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showChatModal,
        child: Icon(Icons.chat),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
