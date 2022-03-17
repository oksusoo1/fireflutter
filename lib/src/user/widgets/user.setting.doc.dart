import 'dart:async';

import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

/// UserSettingDoc
///
///
class UserSettingDoc extends StatefulWidget {
  const UserSettingDoc({required this.builder, Key? key}) : super(key: key);
  final Widget Function(UserSettingsModel) builder;

  @override
  State<UserSettingDoc> createState() => _SettingsState();
}

class _SettingsState extends State<UserSettingDoc> {
  UserSettingsModel settings = UserSettingsModel.empty();

  // ignore: cancel_subscriptions
  late StreamSubscription sub;

  @override
  void initState() {
    super.initState();

    sub = UserSettingService.instance.changes.listen(
      (v) => setState(
        () {
          settings = v;
        },
      ),
    );
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
