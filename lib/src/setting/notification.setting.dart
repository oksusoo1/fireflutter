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
  final commentNotification = "newCommentUnderMyPostOrComment";

  List<CategoryModel>? categories;

  @override
  void initState() {
    super.initState();
    // CategoryService.instance.getCategories().then((v) => setState(() {}));
    CategoryService.instance
        .loadCategories(categoryGroup: 'community')
        .then((value) => setState(() => categories = value));
  }

  @override
  Widget build(BuildContext context) {
    // if (loading) return Center(child: CircularProgressIndicator.adaptive());
    return StreamBuilder(
      stream: UserSettingService.instance.changes.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error');
        if (snapshot.connectionState == ConnectionState.waiting)
          return SizedBox.shrink();
        if (snapshot.hasData == false) return SizedBox.shrink();
        // print(UserSettingService.instance.settings.topics);

        if (categories == null)
          return Center(
            child: CircularProgressIndicator.adaptive(),
          );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              value: UserSettingService.instance
                  .hasSubscription(commentNotification),
              onChanged: (b) {
                if (b == true) {
                  UserSettingService.instance
                      .subscribe(commentNotification)
                      .catchError(widget.onError);
                } else {
                  UserSettingService.instance
                      .unsubscribe(commentNotification)
                      .catchError(widget.onError);
                }
              },
              title: Text('Comment notifications'),
              subtitle: Text(
                  'Receive notifications of new comments under my posts and comments'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            SizedBox(
              height: 64,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: Text(
                'You can enable or disable notifications for new posts or new comments under each forum category. Or you can enable or disable all of them by one button press.',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Row(
              children: [
                Spacer(),
                TextButton(
                  onPressed: () => enableOrDisableAllNotification(true),
                  child: Text('Enable all notification'),
                ),
                TextButton(
                  onPressed: () => enableOrDisableAllNotification(false),
                  child: Text('Disable all notification'),
                ),
                SizedBox(width: 24),
              ],
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
              ),
              child: Text(
                'Post notifications',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            for (CategoryModel cat in categories!)
              CheckboxListTile(
                value: UserSettingService.instance
                    .hasSubscription('posts_${cat.id}'),
                onChanged: (b) => MessagingService.instance
                    .updateSubscription('posts_${cat.id}', b ?? false)
                    .catchError(widget.onError),
                title: Text(cat.title),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
              ),
              child: Text(
                'Comment notifications',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            for (CategoryModel cat in categories!)
              CheckboxListTile(
                value: UserSettingService.instance
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
    for (CategoryModel cat in categories!) {
      MessagingService.instance
          .updateSubscription('posts_${cat.id}', enable)
          .catchError(widget.onError);
      MessagingService.instance
          .updateSubscription('comments_${cat.id}', enable)
          .catchError(widget.onError);
    }
  }
}
