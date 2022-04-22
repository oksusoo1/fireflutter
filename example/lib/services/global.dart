import 'package:flutter/material.dart';

import 'service.dart';

import 'package:fireflutter/fireflutter.dart';

/// 글로벌 navigator key. MaterialApp 에 등록해서, 모든 영역에서 state 나 context 를 사용.
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
