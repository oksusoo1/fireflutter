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
      appBar: AppBar(title: Text('Translations')),
      body: Column(
        children: [
          const Text('Code:'),
          TextField(),
          const Text('en:'),
          TextField(),
          const Text('ko:'),
          TextField(),
        ],
      ),
    );
  }
}
