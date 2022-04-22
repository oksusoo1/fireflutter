import 'package:flutter/material.dart';

import 'service.dart';

import 'package:fireflutter/fireflutter.dart';

/// Global navigator key to be registered in MaterialApp for global state & context
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey();

Service service = Service.instance;

/// Short for UserService.instance
UserService my = UserService.instance;

///
extension StringTranslation on String {
  String get tr {
    return TranslationService.instance.tr(this);
  }
}
