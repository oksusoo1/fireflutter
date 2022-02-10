import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class UserSubscriptionsList extends StatefulWidget {
  const UserSubscriptionsList({
    Key? key,
    required this.onError,
  }) : super(key: key);
  final Function onError;

  @override
  _UserSubscriptionsListState createState() => _UserSubscriptionsListState();
}

class _UserSubscriptionsListState extends State<UserSubscriptionsList> {
  Map<String, bool> notifications = {};

  @override
  void initState() {
    super.initState();

    for (String t in UserService.instance.user.topics) {
      notifications[t] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('Notification Subscription'),
      children: [
        for (String n in notifications.keys)
          ListTile(
            title: Text(n),
            trailing: IconButton(
              icon: notifications[n] == true
                  ? Icon(Icons.toggle_on)
                  : Icon(Icons.toggle_off),
              onPressed: () async {
                // save changes
                if (mounted)
                  try {
                    await MessagingService.instance.updateSubscription(n);
                    setState(() {
                      notifications[n] = !notifications[n]!;
                    });
                  } catch (e) {
                    widget.onError(e);
                  }
              },
            ),
          ),
        if (notifications.isEmpty) Text('No Notification Subscriptions yet...'),
      ],
    );
  }
}
