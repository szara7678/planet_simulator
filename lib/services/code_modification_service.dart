// lib/services/code_modification_service.dart
import 'dart:convert';

class CodeModificationService {
  // 동적으로 관리할 시뮬레이션 파라미터를 저장하는 Map
  Map<String, dynamic> simulationParameters = {
    "advancedCreature": {
      "speed": 10.0,
      "reproductionRate": 0.05,
      "consumptionRate": 5.0,
    },
    "environment": {
      "springResourceRegen": 1.2,
      "summerResourceRegen": 1.0,
      "autumnResourceRegen": 0.8,
      "winterResourceRegen": 0.5,
    },
  };

  /// 사용자가 입력한 명령어를 파싱하여 시뮬레이션 파라미터를 수정합니다.
  /// 예: "코드 수정: advancedCreature.speed=12.0"
  String processCommand(String command) {
    // "코드 수정:" 접두어 제거
    String trimmed = command.replaceAll("코드 수정:", "").trim();
    // "key1.key2=value" 형식인지 확인
    List<String> parts = trimmed.split("=");
    if (parts.length != 2) {
      return "명령 형식 오류: key1.key2=value 형식으로 입력해주세요.";
    }
    String keyPath = parts[0].trim();
    String valueStr = parts[1].trim();
    double? value = double.tryParse(valueStr);
    if (value == null) {
      return "값 오류: 숫자 값을 입력해주세요.";
    }
    // keyPath 예: advancedCreature.speed
    List<String> keys = keyPath.split(".");
    if (keys.length != 2) {
      return "키 경로 오류: key1.key2 형식으로 입력해주세요.";
    }
    String category = keys[0];
    String parameter = keys[1];
    if (simulationParameters.containsKey(category)) {
      simulationParameters[category][parameter] = value;
      return "파라미터 수정 성공: $category.$parameter = $value";
    } else {
      return "카테고리 오류: $category 가 존재하지 않습니다.";
    }
  }

  /// 현재 파라미터 상태를 JSON 문자열로 반환 (디버깅 또는 보고용)
  String getParametersAsJson() {
    return jsonEncode(simulationParameters);
  }
}
