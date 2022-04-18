import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'dart:async';
import '../fireflutter.dart';

/// splitQueryString of Uri class
///
/// The difference of [Uri.splitQueryString] is that if the string have '?',
///   then it removes the front part of it.
///   For instance, "/page?a=b&c=d", then it will parse only after '?' that is
///   "a=b&c=d".
///
/// ```dart
/// splitQueryString("/page?a=b&c=d"); // => { "a": "b", "c": "d" }
/// ```
Map<String, String> splitQueryString(String query) {
  if (query.indexOf('?') != -1) {
    query = query.substring(query.indexOf('?') + 1);
  }
  return query.split("&").fold({}, (map, element) {
    int index = element.indexOf("=");
    if (index == -1) {
      if (element != "") {
        map[element] = "";
      }
    } else if (index != 0) {
      var key = element.substring(0, index);
      var value = element.substring(index + 1);
      map[key] = value;
    }
    return map;
  });
}

/// Produce links for firestore indexes generation.
///
/// Once indexes are set, it will not produce the links any more.
/// Wait for 30 minutes after clicnk the links for the completion.
getFirestoreIndexLinks() {
  ReminderService.instance.settingsCol
      .where('type', isEqualTo: 'reminder')
      .where('link', isNotEqualTo: 'abc')
      .get();
}

/// Bouncer
///
/// It's very similary to 'debounce' functionality, and it's more handy to use.
/// ```dart
/// TextField(onChanged: () {
///   bounce('nickname', 500, (s) {
///     debugPrint('debounce: $s');
///   }, seed: 'nickname update');
///   bounce('3 seconds', 3000, (s) {
///     debugPrint('debounce: $s');
///   }, seed: '3 seconds delay');
/// })
/// ```
///
/// - Example of display loader while saving.
///
/// ```dart
/// setState(() => nicknameLoader = true);
/// bounce('nickname', 500, (s) async {
///   await UserService.instance.user.updateNickname(t).catchError(error);
///   setState(() => nicknameLoader = false);
/// });
/// ```
final Map<String, Timer> debounceTimers = {};
bounce(
  String debounceId,
  int milliseconds,
  Function(dynamic) action, {
  dynamic seed,
}) {
  debounceTimers[debounceId]?.cancel();
  debounceTimers[debounceId] = Timer(Duration(milliseconds: milliseconds), () {
    action(seed);
    debounceTimers.remove(debounceId);
  });
}

/// EO of bouncer

/// Wait until
Future<int> waitUntil(bool test(),
    {final int maxIterations: 100,
    final Duration step: const Duration(milliseconds: 50)}) async {
  int iterations = 0;
  for (; iterations < maxIterations; iterations++) {
    await Future.delayed(step);
    if (test()) {
      break;
    }
  }
  if (iterations >= maxIterations) {
    throw TimeoutException(
        "Condition not reached within ${iterations * step.inMilliseconds}ms");
  }
  return iterations;
}

/// EO wait until

Future<String> getAbsoluteTemporaryFilePath(String relativePath) async {
  var directory = await getTemporaryDirectory();
  return p.join(directory.path, relativePath);
}

/// Return UUID
String getRandomString({int len = 16, String? prefix}) {
  const uuid = Uuid();
  return uuid.v4();

  // const charset = 'abcdefghijklmnopqrstuvwxyz0123456789';
  // var t = '';
  // for (var i = 0; i < len; i++) {
  //   t += charset[(Random().nextInt(charset.length))];
  // }
  // if (prefix != null && prefix.isNotEmpty) t = prefix + t;
  // return t;
}

/// Returns a Color from hex string.
///
/// It takes a 6 (no alpha channel) or 8 (with alpha channel) character string,
/// with or without the # prefix.
///
/// [defaultColor] is the color that will be returned if [hexColor] is malformed.
///
/// If it can't parse hex string, it returns [defaultColor].
///
/// ```dart
/// getColorFromHex('123456');
/// getColorFromHex('#123456');
/// getColorFromHex('12345678');
/// getColorFromHex('#12345678');
/// getColorFromHex(''); // error. Returns [defaultColor] color.
/// ```
Color getColorFromHex(
  String hexColor, [
  Color defaultColor = const Color(0xFFFFFFFF),
]) {
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
    return Color(int.parse("0x$hexColor"));
  } else if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  } else {
    return defaultColor;
  }
}

bool isImageUrl(String url) {
  String t = url.toLowerCase();
  if (t.endsWith('.jpg')) return true;
  if (t.endsWith('.jpeg')) return true;
  if (t.endsWith('.png')) return true;
  if (t.endsWith('.gif')) return true;

  if (t.startsWith('http') &&
      (t.contains('.jpg') ||
          t.contains('.jpeg') ||
          t.contains('.png') ||
          t.contains('.gif'))) return true;
  return false;
}

/// Return true if the message is a URL of uploaded file in Firebase Storage.
bool isFirebaseStorageUrl(String url) {
  return url.contains('firebasestorage.googleapis.com');
}

/// Returns short date time string from Firestore Timestamp
///
/// It returns one of 'MM/DD/YYYY' or 'HH:MM AA' format.
String shortDateTime(createdAt) {
  final date =
      DateTime.fromMillisecondsSinceEpoch(createdAt.millisecondsSinceEpoch);
  final today = DateTime.now();
  bool re;
  if (date.year == today.year &&
      date.month == today.month &&
      date.day == today.day) {
    re = true;
  } else {
    re = false;
  }
  return re
      ? DateFormat.jm().format(date).toLowerCase()
      : DateFormat.yMd().format(date);
}

/// Alias of `shortDateTime()`.
String shortDateTimeFromFirestoreTimestamp(timestamp) {
  return shortDateTime(timestamp);
}

class NotificationOptions {
  static String notifyPost = 'posts_';
  static String notifyComment = 'comments_';
  static String notifyJobs = 'jobs_';

  static String post(String topic) {
    return notifyPost + topic;
  }

  static String comment(String topic) {
    return notifyComment + topic;
  }

  static String jobs(String topic) {
    return notifyComment + topic;
  }
}
