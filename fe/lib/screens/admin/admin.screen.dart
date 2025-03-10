import 'package:extended/extended.dart';
import 'package:fe/services/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  static const String routeName = '/admin';

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    // print('initState;');
    UserService.instance.updateAdminStatus().then((value) => setState(() => {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // print('didChangeDependencies;');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Screen'),
      ),
      body: AdminOnly(
        child: PagePadding(
          children: [
            UserService.instance.user.isAdmin
                ? const Text('You are an admin')
                : const Text('You are not admin'),
            Divider(),
            Text('Forum Management'),
            Wrap(
              children: [
                ElevatedButton(
                  onPressed: AppService.instance.router.openCategoryGroup,
                  child: Text('Category Group'),
                ),
                spaceXxs,
                ElevatedButton(
                  onPressed: AppService.instance.router.openCategory,
                  child: const Text('Category'),
                ),
              ],
            ),
            Divider(),
            ElevatedButton(
                onPressed: AppService.instance.router.openTranslations,
                child: Text('Update Translations')),
            Divider(),
            Text('Report Management'),
            Wrap(
              children: [
                ElevatedButton(
                  onPressed: AppService.instance.router.openReport,
                  child: const Text('All'),
                ),
                ElevatedButton(
                  onPressed: () => AppService.instance.router.openReport('post'),
                  child: const Text('Posts'),
                ),
                ElevatedButton(
                  onPressed: () => AppService.instance.router.openReport('comment'),
                  child: const Text('Comments'),
                ),
                ElevatedButton(
                  onPressed: () => AppService.instance.router.openReport('user'),
                  child: const Text('Users'),
                ),
              ],
            ),
            Divider(),
            Wrap(
              children: [
                ElevatedButton(
                  onPressed: () => AppService.instance.router.open('/pushNotification'),
                  child: const Text('Push Notification'),
                ),
                ElevatedButton(
                  onPressed: () => AppService.instance.router
                      .open('/pushNotification', arguments: {'postId': '0EWGGe64ckjBtiU1LeB1'}),
                  child: const Text('Push Notification with postId'),
                )
              ],
            ),
            ElevatedButton(
                onPressed: () => alert(
                    'Create test users', "Run \$ node create.test.user.js in firebase/lab foler."),
                child: Text('Create test users')),
          ],
        ),
      ),
    );
  }
}
