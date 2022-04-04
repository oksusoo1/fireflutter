import '../../fireflutter.dart';
import 'package:flutter/material.dart';

class PointHistory extends StatefulWidget {
  const PointHistory({
    Key? key,
  }) : super(key: key);
  @override
  State<PointHistory> createState() => _PointHistoryState();
}

class _PointHistoryState extends State<PointHistory> {
  List<PointHistoryModel> histories = [];

  @override
  void initState() {
    super.initState();

    init();
  }

  init() async {
    try {
      histories = await PointApi.instance.getHistory(year: 2022, month: 4);
      setState(() {});
    } catch (e) {
      FunctionsApi.instance.onError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: histories.length,
        itemBuilder: ((context, index) {
          PointHistoryModel history = histories[index];

          /// TODO: 보기 좋게 처리. eventName 을 친숙한 용어로 변경, timestamp 를 적절한 시간으로 변경.
          /// TODO: 년도와 날짜 선택 가능하게 처리
          /// TODO: 각 목록의 처음 포인트와 맨 마지막 포인트까지 계산을 해서 이상이 있으면 표시 할 것. (이렇게 하기 위해서는 변경 후, 나의 포인트를 같이 기록해야 함.)
          return ListTile(
            title: Text(history.eventName),
            subtitle: Text("Point. ${history.point} at ${history.timestamp}"),
          );
        }));
  }
}
