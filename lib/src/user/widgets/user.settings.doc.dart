import 'dart:async';

import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

/// UserSettingsDoc
///
///
class UserSettingsDoc extends StatefulWidget {
  const UserSettingsDoc({required this.builder, Key? key}) : super(key: key);
  final Widget Function(UserSettingsModel) builder;

  @override
  State<UserSettingsDoc> createState() => _SettingsState();
}

class _SettingsState extends State<UserSettingsDoc> {
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
