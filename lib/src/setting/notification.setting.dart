import '../../fireflutter.dart';
import 'package:flutter/material.dart';

class NotificationSetting extends StatefulWidget {
  const NotificationSetting({
    Key? key,
    required this.onError,
  }) : super(key: key);
  final Function onError;

  @override
  State<NotificationSetting> createState() => _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
  @override
  void initState() {
    super.initState();
    CategoryService.instance.getCategories().then((v) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    // if (loading) return Center(child: CircularProgressIndicator.adaptive());
    return StreamBuilder(
      stream: UserSettingsService.instance.changes.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error');
        if (snapshot.connectionState == ConnectionState.waiting)
          return SizedBox.shrink();
        if (snapshot.hasData == false) return SizedBox.shrink();
        print(UserSettingsService.instance.settings.topics);
        return Column(
          children: [
            ElevatedButton(
              onPressed: () => enableOrDisableAllNotification(true),
              child: Text('Enable all notification'),
            ),
            ElevatedButton(
              onPressed: () => enableOrDisableAllNotification(false),
              child: Text('Disable all notification'),
            ),
            Text('Post notification'),
            for (CategoryModel cat in CategoryService.instance.categories)
              CheckboxListTile(
                value: UserSettingsService.instance
                    .hasSubscription('posts_${cat.id}'),
                onChanged: (b) => MessagingService.instance
                    .updateSubscription('posts_${cat.id}', b ?? false)
                    .catchError(widget.onError),
                title: Text(cat.title),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            Text('Comment notification'),
            for (CategoryModel cat in CategoryService.instance.categories)
              CheckboxListTile(
                value: UserSettingsService.instance
                    .hasSubscription('comments_${cat.id}'),
                onChanged: (b) => MessagingService.instance
                    .updateSubscription('comments_${cat.id}', b ?? false)
                    .catchError(widget.onError),
                title: Text(cat.title),
                controlAffinity: ListTileControlAffinity.leading,
              ),
          ],
        );
      },
    );
  }

  enableOrDisableAllNotification([bool enable = true]) {
    for (CategoryModel cat in CategoryService.instance.categories) {
      MessagingService.instance
          .updateSubscription('posts_${cat.id}', enable)
          .catchError(widget.onError);
      MessagingService.instance
          .updateSubscription('comments_${cat.id}', enable)
          .catchError(widget.onError);
    }
  }
}
