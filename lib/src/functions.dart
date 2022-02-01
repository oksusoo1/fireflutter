import '../fireflutter.dart';

import 'dart:async';

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
///   bouncer('nickname', 500, (x) {
///     debugPrint('debounce: $x');
///   }, seed: 'nickname update');
///   bouncer('3 seconds', 3000, (x) {
///     debugPrint('debounce: $x');
///   }, seed: '3 seconds delay');
/// })
/// ```
final Map<String, Timer> debounceTimers = {};
bouncer(
  String debounceId,
  int milliseconds,
  Function action, {
  dynamic seed,
}) {
  debounceTimers[debounceId]?.cancel();
  debounceTimers[debounceId] = Timer(Duration(milliseconds: milliseconds), () {
    action(seed);
    debounceTimers.remove(debounceId);
  });
}

/// EO of bouncer
