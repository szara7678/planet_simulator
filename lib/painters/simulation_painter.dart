// lib/painters/simulation_painter.dart
import 'package:flutter/material.dart';
import '../models/advanced_creature.dart';
import '../models/resource.dart';

class SimulationPainter extends CustomPainter {
  final List<AdvancedCreature> creatures;
  final List<Resource> resources;

  SimulationPainter({required this.creatures, required this.resources});

  @override
  void paint(Canvas canvas, Size size) {
    final double creatureRadius = 5;
    final Paint creaturePaint = Paint()..color = Colors.red;

    // AdvancedCreature를 wrap-around 로직으로 그리기
    for (AdvancedCreature creature in creatures) {
      Offset pos = Offset(creature.x, creature.y);
      _drawCircleWithWrap(canvas, pos, size, creatureRadius, creaturePaint);
    }

    // 자원(Resource)도 동일한 방식으로 그리기
    for (Resource resource in resources) {
      Offset pos = Offset(resource.x, resource.y);
      Paint resourcePaint = Paint()
        ..color = resource.type == "식량" ? Colors.green : Colors.blue;
      // 자원의 양에 따라 크기 결정 (최소 3, 최대 8)
      double radius = 3 + (resource.quantity / 100) * 5;
      _drawCircleWithWrap(canvas, pos, size, radius, resourcePaint);
    }
  }

  void _drawCircleWithWrap(Canvas canvas, Offset pos, Size size, double radius, Paint paint) {
    // 기본 위치에 그리기
    canvas.drawCircle(pos, radius, paint);

    // 좌우, 상하 및 대각선 위치에 wrap-around 효과 적용
    if (pos.dx < radius) {
      canvas.drawCircle(Offset(pos.dx + size.width, pos.dy), radius, paint);
    }
    if (pos.dx > size.width - radius) {
      canvas.drawCircle(Offset(pos.dx - size.width, pos.dy), radius, paint);
    }
    if (pos.dy < radius) {
      canvas.drawCircle(Offset(pos.dx, pos.dy + size.height), radius, paint);
    }
    if (pos.dy > size.height - radius) {
      canvas.drawCircle(Offset(pos.dx, pos.dy - size.height), radius, paint);
    }
    if (pos.dx < radius && pos.dy < radius) {
      canvas.drawCircle(Offset(pos.dx + size.width, pos.dy + size.height), radius, paint);
    }
    if (pos.dx < radius && pos.dy > size.height - radius) {
      canvas.drawCircle(Offset(pos.dx + size.width, pos.dy - size.height), radius, paint);
    }
    if (pos.dx > size.width - radius && pos.dy < radius) {
      canvas.drawCircle(Offset(pos.dx - size.width, pos.dy + size.height), radius, paint);
    }
    if (pos.dx > size.width - radius && pos.dy > size.height - radius) {
      canvas.drawCircle(Offset(pos.dx - size.width, pos.dy - size.height), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
