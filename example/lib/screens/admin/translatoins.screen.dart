import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class TranslationsScreen extends StatefulWidget {
  const TranslationsScreen({Key? key}) : super(key: key);

  static final String routeName = '/translations';

  @override
  State<TranslationsScreen> createState() => _TranslationsScreenState();
}

class _TranslationsScreenState extends State<TranslationsScreen> {
  Map<String, Map<String, String>>? texts;

  @override
  void initState() {
    super.initState();
    TranslationService.instance.get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Translations'),
        actions: [IconButton(onPressed: showForm, icon: Icon(Icons.create))],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [],
      ),
    );
  }

  /// @TODO: 여기서부터... 생성과 수정은 타이틀바와, 각 라인에 표시.
  /// @TODO: 저장 할 때, 모든 code 와 en, ko 를 하나의 문서에 업데이트한다.
  /// @TODO: 보여 줄 때, 하나의 문서를 읽어, 모두에 보여준다.
  showForm() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Translation form'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('code:'),
            TextField(),
            const Text('en:'),
            TextField(),
            const Text('ko:'),
            TextField(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {},
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
