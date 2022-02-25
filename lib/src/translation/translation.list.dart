import 'package:flutter/material.dart';
import '../../fireflutter.dart';

class TranslationList extends StatelessWidget with DatabaseMixin {
  const TranslationList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder(
          stream: TranslationService.instance.changes.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData == false)
              return Center(child: CircularProgressIndicator.adaptive());
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final code in TranslationService.instance.texts.keys)
                  ListTile(
                    title: Text(code),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'en: ${TranslationService.instance.texts[code]!['en'] ?? ''}',
                        ),
                        Text(
                          'ko: ${TranslationService.instance.texts[code]!['ko'] ?? ''}',
                        )
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      child: Icon(Icons.menu),
                      onSelected: (s) {
                        if (s == 'update') {
                          TranslationService.instance.showForm(context, code);
                        }
                        if (s == 'delete') {
                          translationDoc.update({
                            code: null,
                          });
                        }
                      },
                      itemBuilder: (c) => <PopupMenuEntry<String>>[
                        const PopupMenuItem(
                          child: Text('Update'),
                          value: 'update',
                        ),
                        const PopupMenuItem(
                          child: Text('Delete'),
                          value: 'delete',
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }),
    );
  }
}
