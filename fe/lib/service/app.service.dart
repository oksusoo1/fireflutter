import 'dart:developer';

import 'package:extended/extended.dart' as ex;
import 'package:fe/service/app.router.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AppService {
  static AppService? _instance;
  static AppService get instance {
    if (_instance == null) {
      _instance = AppService();
    }
    return _instance!;
  }

  final router = AppRouter.instance;

  error(e, [StackTrace? stack]) {
    debugPrint('===> service.error();');
    debugPrint(e.toString());
    if (stack != null) {
      debugPrintStack(stackTrace: stack);
    }

    if (e.toString() == 'IMAGE_NOT_SELECTED') return;

    final ErrorInfo info = ErrorInfo.from(e);
    if (info.level == ErrorLevel.minor) {
      log('--> Ignore minor error; ${info.title}, ${info.content}');
      return;
    }
    ex.alert(
      TranslationService.instance.tr(info.title),
      TranslationService.instance.tr(info.content),
    );
  }
}
