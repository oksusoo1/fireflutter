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

          /// TODO: 년도와 날짜 선택 가능하게 처리
          final d = DateTime.fromMillisecondsSinceEpoch(history.timestamp * 1000);
          return ListTile(
            title: Text(_text(history.eventName)),
            subtitle: Text(
                "Point. ${history.point} at ${d.year}-${d.month}-${d.day} ${d.hour}:${d.minute}:${d.second}"),
          );
        }));
  }

  _text(String t) {
    switch (t) {
      case 'register':
        return 'Registration bonus';
      case 'signIn':
        return 'Sign-in bonus';
      case 'postCreate':
        return 'Post creation bonus';
      case 'commentCreate':
        return 'Comment creation bonus';
      default:
        return t;
    }
  }
}
