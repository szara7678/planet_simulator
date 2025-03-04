// lib/widgets/modals.dart
import 'dart:async';
import 'package:flutter/material.dart';

/// ReportModal: 실시간 업데이트되는 보고서
/// getCurrentSeason, getCreatureGroupReport, getResourceGroupReport 콜백을 통해 정보를 가져옵니다.
class ReportModal extends StatefulWidget {
  final String Function() getCurrentSeason;
  final Map<String, String> Function() getCreatureGroupReport;
  final Map<String, String> Function() getResourceGroupReport;

  ReportModal({
    required this.getCurrentSeason,
    required this.getCreatureGroupReport,
    required this.getResourceGroupReport,
  });

  @override
  _ReportModalState createState() => _ReportModalState();
}

class _ReportModalState extends State<ReportModal> {
  String currentSeason = "";
  Map<String, String> creatureGroupReport = {};
  Map<String, String> resourceGroupReport = {};

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateData();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _updateData();
      });
    });
  }

  void _updateData() {
    currentSeason = widget.getCurrentSeason();
    creatureGroupReport = widget.getCreatureGroupReport();
    resourceGroupReport = widget.getResourceGroupReport();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('행성 상태 보고', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            Text('현재 계절: $currentSeason'),
            SizedBox(height: 8),
            Text('종족별 보고:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ...creatureGroupReport.entries.map((entry) => Text('종족 ${entry.key}: ${entry.value}', style: TextStyle(fontSize: 14))),
            Divider(),
            Text('자원별 보고:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ...resourceGroupReport.entries.map((entry) => Text('자원 ${entry.key}: ${entry.value}', style: TextStyle(fontSize: 14))),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// HistoryModal: 그룹별로 묶인 역사 기록을 실시간 업데이트
class HistoryModal extends StatefulWidget {
  final List<String> Function() getHistoryLogGroup;
  HistoryModal({required this.getHistoryLogGroup});

  @override
  _HistoryModalState createState() => _HistoryModalState();
}

class _HistoryModalState extends State<HistoryModal> {
  List<String> groupedHistory = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateData();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _updateData();
      });
    });
  }

  void _updateData() {
    groupedHistory = widget.getHistoryLogGroup();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('역사 기록 (그룹별)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: groupedHistory.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Text(groupedHistory[index]),
                );
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('닫기'),
            ),
          ),
        ],
      ),
    );
  }
}

/// ChatModal: 기존 대화 모달 (변경 없음)
class ChatModal extends StatefulWidget {
  final Function(String) onSend;
  final List<String> conversationHistory;
  ChatModal({required this.onSend, required this.conversationHistory});
  @override
  _ChatModalState createState() => _ChatModalState();
}
class _ChatModalState extends State<ChatModal> {
  TextEditingController _controller = TextEditingController();
  void _processCommand(String command) {
    List<String> parts = command.split(':');
    if (parts.length >= 2) {
      String cmd = parts[0].trim().toLowerCase();
      String arg = parts.sublist(1).join(':').trim();
      widget.onSend("명령 처리 - $cmd : $arg");
    } else {
      widget.onSend("명령 인식 실패: $command");
    }
  }
  void _sendMessage() {
    String message = _controller.text.trim();
    if (message.isNotEmpty) {
      widget.onSend("사용자: $message");
      _processCommand(message);
      setState(() {
        widget.conversationHistory.add("사용자: $message");
      });
      _controller.clear();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('최초의신과 대화하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: widget.conversationHistory.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(widget.conversationHistory[index]),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: '명령을 입력하세요 (예: 날씨 변경: 겨울)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: _sendMessage,
                child: Text('전송'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
