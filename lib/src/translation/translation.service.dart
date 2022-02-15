import 'package:rxdart/subjects.dart';

import '../../fireflutter.dart';

/// TranslationService
///
/// Refer readme.md for details.
class TranslationService with DatabaseMixin {
  static TranslationService? _instance;
  static TranslationService get instance {
    _instance ??= TranslationService();
    return _instance!;
  }

  Map<String, Map<String, String>> texts = {};
  // ignore: close_sinks
  BehaviorSubject<Map<String, Map<String, String>>> changes = BehaviorSubject.seeded({});

  TranslationService() {
    translationDoc.onValue.listen((event) {
      if (event.snapshot.exists) {
        texts = event.snapshot.value as Map<String, Map<String, String>>;
        changes.add(texts);
      }
    });
  }
}
