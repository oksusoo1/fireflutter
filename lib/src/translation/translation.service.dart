import 'package:flutter/material.dart';
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
    // debugPrint('===> TranslationService::constructor;');
    translationDoc.onValue.listen((event) {
      if (event.snapshot.exists) {
        convertData(event.snapshot.value);
        // print('onValue; exists; $texts');
        changes.add(texts);
      }
    });
  }

  Future get() async {
    final snapshot = await translationDoc.get();
    if (snapshot.exists) {
      return convertData(snapshot.value);
    } else {
      return null;
    }
  }

  convertData(dynamic data) {
    if (!(data is Map)) return;
    if (data is String) return;

    texts = {};
    for (final k in data.keys) {
      texts[k] = {
        if (data[k]['en'] != null) 'en': data[k]['en'],
        if (data[k]['ko'] != null) 'ko': data[k]['ko'],
      };
    }
    return texts;
  }

  /// @TODO: 여기서부터... 생성과 수정은 타이틀바와, 각 라인에 표시.
  /// @TODO: 저장 할 때, 모든 code 와 en, ko 를 하나의 문서에 업데이트한다.
  /// @TODO: 보여 줄 때, 하나의 문서를 읽어, 모두에 보여준다.
  showForm(BuildContext context, [String? updateCode]) {
    final code = TextEditingController(text: updateCode ?? '');
    final en = TextEditingController(text: texts[updateCode]?['en'] ?? '');
    final ko = TextEditingController(text: texts[updateCode]?['ko'] ?? '');

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Translation form'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('code:'),
            TextField(controller: code),
            SizedBox(height: 16),
            const Text('en:'),
            TextField(controller: en),
            SizedBox(height: 16),
            const Text('ko:'),
            TextField(controller: ko),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final snapshot = await translationDoc.get();
                if (snapshot.exists) {
                  if (updateCode != null) {
                    translationDoc.update({
                      updateCode: null,
                    });
                  }
                  translationDoc.update({
                    code.text: {
                      'en': en.text,
                      'ko': ko.text,
                    },
                  });
                } else {
                  translationDoc.set({
                    code.text: {
                      'en': en.text,
                      'ko': ko.text,
                    },
                  });
                }
                Navigator.pop(context);
              } catch (e) {
                debugPrint('====> error on updating translation; $e');
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
