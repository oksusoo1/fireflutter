import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class TranslationsScreen extends StatefulWidget {
  const TranslationsScreen({Key? key}) : super(key: key);

  static final String routeName = '/translations';

  @override
  State<TranslationsScreen> createState() => _TranslationsScreenState();
}

class _TranslationsScreenState extends State<TranslationsScreen> {


  @override
  void initState() {
    super.initState();
    Translations
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Translations')),
      body: Container(),
    );
  }
}
