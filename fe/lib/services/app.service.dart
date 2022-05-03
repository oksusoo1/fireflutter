import 'dart:developer';

import 'package:extended/extended.dart' as ex;
import 'package:fe/services/app.router.dart';
import 'package:fe/services/click_sound.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/foundation.dart';

class AppService {
  static AppService? _instance;
  static AppService get instance {
    if (_instance == null) {
      _instance = AppService();
    }
    return _instance!;
  }

  AppService() {
    ClickSoundService.instance.init();
  }

  Future pageTransitionSound() {
    return ClickSoundService.instance.play();
  }

  final router = AppRouter.instance;

  error(e, [StackTrace? stack]) {
    debugPrint('===> AppService.error();');
    debugPrint(e.toString());
    if (stack != null) {
      debugPrintStack(stackTrace: stack);
    }

    if (e.toString() == 'IMAGE_NOT_SELECTED') return;

    final ErrorInfo info = ErrorInfo.from(e);
    if (info.level == ErrorLevel.minor) {
      log('--> --> --> [ Ignore minor error & will be ignored in release ] - ${info.title}, ${info.content}');
      if (kReleaseMode) return;
    }
    ex.alert(
      TranslationService.instance.tr(info.title),
      TranslationService.instance.tr(info.content),
    );
  }

  /// Open alert box
  ///
  /// Alert box does return value.
  /// ```dart
  /// service.alert('Alert', 'This is an alert box')
  /// ```
  Future<void> alert(String title, String content) async {
    ex.alert(title, content);
  }

  Future<bool> confirm(String title, String content) async {
    return ex.confirm(title, content);
  }
}
