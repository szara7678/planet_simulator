// lib/services/environment_service.dart
import 'dart:async';
import 'dart:math';

enum Season { Spring, Summer, Autumn, Winter }
enum Weather { Clear, Cloudy, Rain, Storm }

class EnvironmentService {
  Season currentSeason = Season.Spring;
  Weather currentWeather = Weather.Clear;

  double resourceRegenMultiplier = 1.0;
  double energyConsumptionMultiplier = 1.0;

  // 각 계절과 날씨가 지속되는 시간(초)
  final int seasonDurationSeconds;
  final int weatherDurationSeconds;

  Timer? _seasonTimer;
  Timer? _weatherTimer;
  final List<Season> seasons = Season.values;
  final List<Weather> weathers = Weather.values;
  int _currentSeasonIndex = 0;

  EnvironmentService({this.seasonDurationSeconds = 30, this.weatherDurationSeconds = 15}) {
    _startSeasonCycle();
    _startWeatherCycle();
    _updateMultipliers();
  }

  void _startSeasonCycle() {
    _seasonTimer = Timer.periodic(Duration(seconds: seasonDurationSeconds), (timer) {
      _currentSeasonIndex = (_currentSeasonIndex + 1) % seasons.length;
      currentSeason = seasons[_currentSeasonIndex];
      _updateMultipliers();
      print("Season changed: $currentSeason, Regen: $resourceRegenMultiplier, Consumption: $energyConsumptionMultiplier");
    });
  }

  void _startWeatherCycle() {
    _weatherTimer = Timer.periodic(Duration(seconds: weatherDurationSeconds), (timer) {
      // Random하게 날씨 변경
      currentWeather = weathers[Random().nextInt(weathers.length)];
      _updateMultipliers();
      print("Weather changed: $currentWeather, Regen: $resourceRegenMultiplier, Consumption: $energyConsumptionMultiplier");
    });
  }

  void _updateMultipliers() {
    // 계절에 따른 기본 배수 설정
    switch (currentSeason) {
      case Season.Spring:
        resourceRegenMultiplier = 1.2;
        energyConsumptionMultiplier = 0.9;
        break;
      case Season.Summer:
        resourceRegenMultiplier = 1.0;
        energyConsumptionMultiplier = 1.0;
        break;
      case Season.Autumn:
        resourceRegenMultiplier = 0.8;
        energyConsumptionMultiplier = 1.1;
        break;
      case Season.Winter:
        resourceRegenMultiplier = 0.5;
        energyConsumptionMultiplier = 1.3;
        break;
    }
    // 날씨에 따른 수정: 날씨 조건이 배수에 추가 효과를 줍니다.
    switch (currentWeather) {
      case Weather.Clear:
      // 변화 없음
        break;
      case Weather.Cloudy:
        resourceRegenMultiplier *= 1.05;
        energyConsumptionMultiplier *= 1.0;
        break;
      case Weather.Rain:
        resourceRegenMultiplier *= 1.2;
        energyConsumptionMultiplier *= 0.95;
        break;
      case Weather.Storm:
        resourceRegenMultiplier *= 0.8;
        energyConsumptionMultiplier *= 1.2;
        break;
    }
  }

  void dispose() {
    _seasonTimer?.cancel();
    _weatherTimer?.cancel();
  }
}
