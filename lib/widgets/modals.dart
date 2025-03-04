// lib/widgets/modals.dart
import 'package:flutter/material.dart';

/// 고급 대화 모달: 사용자의 명령과 시스템 응답 내역을 스크롤 가능한 리스트로 표시
class ChatModal extends StatefulWidget {
  final Function(String) onSend;
  final List<String> conversationHistory;

  ChatModal({required this.onSend, required this.conversationHistory});

  @override
  _ChatModalState createState() => _ChatModalState();
}

class _ChatModalState extends State<ChatModal> {
  TextEditingController _controller = TextEditingController();

  // 명령어 파서 예시: 입력된 텍스트를 분석하여 명령어와 파라미터를 추출
  void _processCommand(String command) {
    // 간단한 파서: 콜론(:)을 기준으로 명령어와 인자를 분리
    List<String> parts = command.split(':');
    if (parts.length >= 2) {
      String cmd = parts[0].trim().toLowerCase();
      String arg = parts.sublist(1).join(':').trim();
      // 예: "날씨 변경: 겨울" -> cmd: "날씨 변경", arg: "겨울"
      widget.onSend("명령 처리 - $cmd : $arg");
      // 실제로는 이 부분에서 해당 명령어를 해석해 simulation_screen에서 처리하도록 전달
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
          Text(
            '최초의신과 대화하기',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
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

/// ResourceData 클래스: 업데이트 시간과 자원 수치를 저장합니다.
class ResourceData {
  final int time;
  final int resource;
  ResourceData(this.time, this.resource);
}

/// 보고 모달: 생명체와 자원을 그룹별로 정리하여 보여줍니다.
class ReportModal extends StatelessWidget {
  final int resourceCount;
  final int totalCreatures;
  final double avgCreatureEnergy;
  final Map<String, dynamic> creatureGroupReport;
  final Map<String, dynamic> resourceGroupReport;

  ReportModal({
    required this.resourceCount,
    required this.totalCreatures,
    required this.avgCreatureEnergy,
    required this.creatureGroupReport,
    required this.resourceGroupReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '행성 상태 보고',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Text('현재 자원 수치: $resourceCount'),
            SizedBox(height: 8),
            Text('전체 생명체 수: $totalCreatures'),
            SizedBox(height: 8),
            Text('평균 생명체 에너지: ${avgCreatureEnergy.toStringAsFixed(1)}'),
            Divider(),
            Text('종족별 보고:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ...creatureGroupReport.entries.map((entry) => Text(
              '종족 ${entry.key}: ${entry.value}',
              style: TextStyle(fontSize: 14),
            )),
            Divider(),
            Text('자원별 보고:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ...resourceGroupReport.entries.map((entry) => Text(
              '자원 ${entry.key}: ${entry.value}',
              style: TextStyle(fontSize: 14),
            )),
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

/// 역사 모달: 시뮬레이션 로그를 시간 정보와 함께 표시
class HistoryModal extends StatelessWidget {
  final List<String> historyLog;

  HistoryModal({required this.historyLog});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6, // 60% 높이로 표시
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '역사 기록',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: historyLog.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Text(historyLog[index]),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('닫기'),
          ),
        ],
      ),
    );
  }
}
