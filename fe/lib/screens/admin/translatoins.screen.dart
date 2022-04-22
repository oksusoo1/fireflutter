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
        title: Tr('Translations'),
        actions: [
          IconButton(
            onPressed: () => TranslationService.instance.showForm(context),
            icon: Icon(Icons.create),
          ),
        ],
      ),
      body: TranslationList(),
    );
  }
}
