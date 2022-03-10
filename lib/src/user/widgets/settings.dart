import 'dart:async';

import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

/// Settings
///
///
class Settings extends StatefulWidget {
  const Settings({required this.builder, Key? key}) : super(key: key);
  final Widget Function(UserSettingsModel) builder;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  UserSettingsModel settings = UserSettingsModel.empty();

  // ignore: cancel_subscriptions
  late StreamSubscription sub;

  @override
  void initState() {
    super.initState();

    sub = UserSettingsService.instance.changes.listen((v) => setState(() => settings = v));
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(settings);
  }
}
