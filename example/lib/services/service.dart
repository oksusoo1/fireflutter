import 'dart:async';

import 'package:example/services/app.router.dart';
import 'package:example/services/defines.dart';
import 'package:example/services/error_info.dart';
import 'package:example/services/global.dart';
import 'package:example/widgets/app_alert_dialog/app_alert_dialog.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class Service {
  static Service? _instance;
  static Service get instance {
    _instance ??= Service();
    return _instance!;
  }

  AppRouter router = AppRouter.instance;

  Service() {
    init();
  }

  /// Dio may produce consecutive errors when there are network problems.
  /// It catches those consecutive erros and reduces into one.
  PublishSubject<int> dioNoInternetError = PublishSubject();
  PublishSubject<int> dioConnectionError = PublishSubject();

  BuildContext get context => globalNavigatorKey.currentContext!;

  init() async {
    /// Display toast error debounced by a second on `No Internet`
    dioNoInternetError.debounceTime(const Duration(seconds: 1)).listen(
          (x) => alert(
            "No Internet", // title
            "Oops! Your device is not connected to the Internet, or the speed of Internet is very slow. Please check internet connectivity. And see if this app allowed to use mobile data when your are using mobile data", // message
          ),
        );

    /// Display toast error debounded by 2 seconds on `Connection error to server`.
    /// This happens when internet is slow and the client sometimes cannot connect to server.
    dioConnectionError.throttleTime(const Duration(seconds: 2)).listen(
          (x) => toast(
            'Connection Error',
            'Please check your connection. This error may happens on slow internet connection.',
            duration: 10,
          ),
        );
  }

  /// Open alert box
  ///
  /// Alert box does return value.
  /// ```dart
  /// service.alert('Alert', 'This is an alert box')
  /// ```
  Future<void> alert(String title, String content) async {
    return dialog(
      title: title,
      content: Text(
        content,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Future confirm(
    String title,
    String content, {
    Function? onYes,
    Function? onNo,
  }) async {
    List<Widget> actions = [
      TextButton(
        onPressed: () {
          Navigator.pop(context, true);
          if (onYes != null) onYes();
        },
        child: const Text('Yes'),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context, false);
          if (onNo != null) onNo();
        },
        child: const Text('No'),
      ),
    ];
    return dialog(
      title: title,
      content: Text(
        content,
        style: const TextStyle(fontSize: 14),
      ),
      actions: actions,
    );
  }

  /// Display app dialog
  ///
  /// * Attention, it does not return value. But you can do whatever with action buttons.
  Future dialog({
    required String title,
    required Widget content,
    List<Widget>? actions,
  }) {
    actions ??= [
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Ok'),
      ),
    ];
    return showDialog(
      context: context,
      builder: (_) => AppAlertDialog(
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }

  /// ```dart
  /// service.toast(
  ///   'This is the title.',
  ///   'This is the message of long text. very very very long long long text. And the long long long long text',
  ///   icon: Icon(
  ///     Icons.notification_add,
  ///     color: Colors.white,
  ///   ),
  ///   actions: [
  ///     TextButton(
  ///       onPressed: () {},
  ///       child: Text('Open'),
  ///     ),
  ///     TextButton(
  ///       onPressed: () {},
  ///       child: Text('Close'),
  ///     ),
  ///   ],
  ///   duration: 20,
  ///   backgroundColor: Color.fromARGB(176, 62, 62, 62),
  ///   onTap: service.hideSnackBar, // close snack bar. You should not use it with actions.
  /// )
  /// ```
  toast(
    String title,
    String message, {
    Function()? onTap,
    Widget? icon,
    int duration = 10,
    Color? backgroundColor,
    List<Widget> actions = const [],
  }) {
    iconSnackbar(
      title,
      message,
      onTap: onTap,
      icon: icon,
      duration: duration,
      backgroundColor: backgroundColor,
      actions: actions,
    );
  }

  /// Opens a warning snackbar
  ///
  iconSnackbar(
    String title,
    String message, {
    Function()? onTap,
    Widget? icon,
    int duration = 10,
    Color? backgroundColor,
    List<Widget> actions = const [],
  }) {
    Widget child = Row(
      children: [
        if (icon != null) ...[icon, spaceSm],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title),
              Text(message),
            ],
          ),
        ),
        ...actions,
      ],
    );
    if (onTap != null) {
      child = GestureDetector(
        child: child,
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: child,
        duration: const Duration(seconds: 10),
      ),
    );
  }

  /// Error handler
  ///
  ///
  /// You have a change to handle error message here, before passing the defualt error handler of utils.
  error(e, [StackTrace? stack]) {
    debugPrint('===> service.error();');
    debugPrint(e.toString());
    if (stack != null) {
      debugPrintStack(stackTrace: stack);
    }

    if (e.toString() == 'IMAGE_NOT_SELECTED') return;

    final ErrorInfo? info = errorInfo(e);
    if (info != null) {
      alert(
        TranslationService.instance.tr(info.title),
        TranslationService.instance.tr(info.content),
      );
    }
  }
}
