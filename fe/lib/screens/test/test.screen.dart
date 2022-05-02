import 'dart:async';

import 'package:extended/extended.dart';
import 'package:fe/screens/admin/admin.search_settings.screen.dart';
import 'package:fe/screens/chat/chat.rooms.screen.dart';
import 'package:fe/screens/friend_map/friend_map.screen.dart';
import 'package:fe/screens/help/help.screen.dart';
import 'package:fe/screens/job/job.list.screen.dart';
import 'package:fe/screens/job/job.seeker.profile.screen.dart';
import 'package:fe/screens/job/job.seeker.list.screen.dart';
import 'package:fe/screens/phone_sign_in/phone_sign_in.screen.dart';
import 'package:fe/screens/phone_sign_in_ui/phone_sign_in_ui.screen.dart';
import 'package:fe/screens/point_history/point_history.screen.dart';
import 'package:fe/screens/reminder/reminder.edit.screen.dart';
import 'package:fe/screens/setting/notification.setting.dart';
import 'package:fe/screens/unit_test/unit_test.screen.dart';
import 'package:fe/services/app.service.dart';
import 'package:fe/services/config.dart';
import 'package:fe/services/defines.dart';
import 'package:fe/widgets/layout/layout.dart';
import 'package:fe/widgets/sign_in.widget.dart';
import 'package:fe/widgets/test.user.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  static const String routeName = '/test';

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  void initState() {
    super.initState();
  }

  final nickname = TextEditingController();
  String uploadUrl = '';

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: Tr(
        'Test screen',
        style: titleStyle,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => AppService.instance.router.open(UnitTestScreen.routeName),
                child: Text('Unit Test Screen'),
              ),
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    User user = snapshot.data!;
                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(sm),
                          child: TextFormField(
                            onFieldSubmitted: (text) =>
                                AppService.instance.router.openSearchScreen(searchKey: text),
                            decoration: InputDecoration(hintText: 'Search ...'),
                          ),
                        ),
                        Text(
                          'You have logged in as ${user.email ?? user.phoneNumber}',
                        ),
                        Text('User Email on Auth: ${user.email}'),
                        Text('User Email on User settings: ${UserService.instance.email}'),
                        MyDoc(
                          builder: (UserModel u) {
                            return Wrap(
                              children: [
                                Text('Profile name: ${u.displayName}'),
                                Text(', photo: ${u.photoUrl}'),
                              ],
                            );
                          },
                        ),
                        Text('UID: ${FirebaseAuth.instance.currentUser?.uid}'),
                        MyDoc(builder: (u) => Text('Point: ${u.point}, Lv: ${u.level}')),
                        MyDoc(builder: (_user) {
                          if (_user.isAdmin)
                            return TextButton(
                                child: const Text(
                                  'You are an admin',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                                onPressed: AppService.instance.router.openAdmin);
                          else
                            return SizedBox();
                        }),
                        Wrap(
                          children: [
                            const EmailButton(),
                            ElevatedButton(
                              onPressed: AppService.instance.router.openProfile,
                              child: const Text('Profile'),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  AppService.instance.router.open(PointHistoryScreen.routeName),
                              child: const Text('Point History'),
                            ),
                            ElevatedButton(
                              onPressed: () => UserService.instance
                                  .signOut(), //  FirebaseAuth.instance.signOut(),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        )
                      ],
                    );
                  } else {
                    return Wrap(
                      children: [
                        ElevatedButton(
                          child: const Text('Sign-In'),
                          onPressed: () {
                            AppService.instance.router.open(SignInWidget.routeName);
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Phone Sign-In'),
                          onPressed: () {
                            AppService.instance.router.open(PhoneSignInScreen.routeName);
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Phone Sign-In UI'),
                          onPressed: () {
                            AppService.instance.router.open(PhoneSignInUIScreen.routeName);
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
              const Divider(),
              ServerTime(),
              const Divider(),
              const Text('Test users;'),
              Wrap(
                alignment: WrapAlignment.spaceAround,
                children: Config.testUsers.values
                    .map(
                      (v) => TestUser(
                        email: v['email']!,
                        name: v['name']!,
                        uid: v['uid']!,
                      ),
                    )
                    .toList(),
              ),
              Wrap(
                children: [
                  ElevatedButton(
                      onPressed: () =>
                          AppService.instance.router.open(HelpScreen.routeName, arguments: {
                            'when': 'Now',
                            'where': 'GimHae',
                            'who': 'Me',
                            'what': 'Working',
                          }),
                      child: const Text('Help')),
                  ElevatedButton(
                    onPressed: () => AppService.instance.router.open(ChatRoomsScreen.routeName),
                    child: const Text('Chat Room List'),
                  ),
                  TextButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('Chat'),
                        ChatBadge(),
                      ],
                    ),
                    onPressed: () {
                      AppService.instance.router.open(ChatRoomsScreen.routeName);
                    },
                  ),
                  TextButton(
                      onPressed: () async {
                        for (int i = 0; i < 10; i++) {
                          setState(() {});
                          await Future.delayed(const Duration(milliseconds: 500));
                        }
                      },
                      child: const Text('setState() 10 times')),
                  const ElevatedButton(
                    onPressed: getFirestoreIndexLinks,
                    child: Text('Get firestore index links'),
                  ),
                  ElevatedButton(
                    onPressed: () => AppService.instance.router.open(FriendMapScreen.routeName),
                    child: const Text('Friend Map'),
                  ),
                  ElevatedButton(
                    onPressed: () => AppService.instance.router.open(ReminderEditScreen.routeName),
                    child: const Text('Reminder Management Screen'),
                  ),
                ],
              ),
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed: () => AppService.instance.router.openPostList(category: 'qna'),
                    child: const Text('QnA'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        AppService.instance.router.openPostList(category: 'discussion'),
                    child: const Text('Discussion'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        AppService.instance.router.openPostList(category: 'buyandsell'),
                    child: const Text('Buy & Sell'),
                  ),
                  ElevatedButton(
                    onPressed: () => AppService.instance.router.open(JobListScreen.routeName),
                    child: const Text('Job'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        AppService.instance.router.open(JobSeekerProfileFormScreen.routeName),
                    child: const Text('Job seeker profile'),
                  ),
                  ElevatedButton(
                    onPressed: () => AppService.instance.router.open(JobSeekerListScreen.routeName),
                    child: const Text('Job seeker list'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text('meilisearch listing'),
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed: () => AppService.instance.router
                        .openSearchScreen(index: 'posts', category: 'qna'),
                    child: const Text('QnA'),
                  ),
                  ElevatedButton(
                    onPressed: () => AppService.instance.router
                        .openSearchScreen(index: 'posts', category: 'discussion'),
                    child: const Text('Discussion'),
                  ),
                  ElevatedButton(
                    onPressed: () => AppService.instance.router
                        .openSearchScreen(index: 'posts', category: 'buyandsell'),
                    child: const Text('Buy & Sell'),
                  ),
                  ElevatedButton(
                    onPressed: () => AppService.instance.router.openSearchScreen(index: 'posts'),
                    child: const Text('Search Screen'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        AppService.instance.router.open(AdminSearchSettingsScreen.routeName),
                    child: const Text('Search Settings'),
                  ),
                ],
              ),
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        AppService.instance.router.open(NotificationSettingScreen.routeName),
                    child: const Text('Notification Setting'),
                  ),
                ],
              ),
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        uploadUrl = await StorageService.instance.pickUpload(
                          type: 'user',
                          source: ImageSource.gallery,
                          onProgress: print,
                        );
                        alert('Success', 'Image uploaded successfully');
                      } catch (e) {
                        // debugPrint('Upload exception; $e');
                        error(e);
                      }
                    },
                    child: const Text('Upload Image'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await StorageService.instance
                            .ref(uploadUrl)
                            .updateMetadata(SettableMetadata(customMetadata: {
                              'updated': 'yes',
                            }));
                        alert('Success', 'Uploaded file updated');
                      } catch (e) {
                        // debugPrint('Update exception; $e');
                        error(e);
                      }
                    },
                    child: const Text('Update Image'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await StorageService.instance.delete(uploadUrl);
                        alert('Success', 'Uploaded file deleted!');
                      } catch (e) {
                        // debugPrint('Delete exception; $e');
                        error(e);
                      }
                    },
                    child: const Text('Delete Image'),
                  ),
                ],
              ),
              Divider(color: Colors.blue),
              Wrap(children: [
                ElevatedButton(
                    onPressed: () => throw 'test-error', child: Text('Throw test-error')),
                ElevatedButton(
                    onPressed: () {
                      String? nul;
                      print('null error; ${nul!}');
                    },
                    child: Text('Throw null check operator error')),
              ]),
              Divider(),
              AdminButton(),
              space3xl,
            ],
          ),
        ),
      ),
    );
  }
}

class ServerTime extends StatefulWidget {
  const ServerTime({
    Key? key,
  }) : super(key: key);

  @override
  State<ServerTime> createState() => _ServerTimeState();
}

class _ServerTimeState extends State<ServerTime> {
  Map? data;
  @override
  void initState() {
    super.initState();
    FunctionsApi.instance
        .request('serverTime')
        .then((value) => setState(() => data = value))
        .catchError((e) => error(e));
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "Sserver time: ${DateTime.fromMillisecondsSinceEpoch((data?['timestamp'] ?? 0) * 1000).toString()}",
    );
  }
}

class AdminButton extends StatelessWidget {
  AdminButton({
    Key? key,
  }) : super(key: key);

  final count = {'count': 0};

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        int c = count['count']!;
        c = c + 1;
        count['count'] = c;
      },
      onLongPress: () {
        if (count['count']! > 3) {
          AppService.instance.router.openAdmin();
        }
      },
      child: const Text('Admin Screen - 3 tap & long press'),
    );
  }
}

class EmailButton extends StatefulWidget {
  const EmailButton({
    Key? key,
  }) : super(key: key);

  @override
  State<EmailButton> createState() => _EmailButtonState();
}

class _EmailButtonState extends State<EmailButton> {
  bool verified = false;

  @override
  void initState() {
    super.initState();

    /// reload and check if verified
    FirebaseAuth.instance.currentUser!.reload().then((value) {
      setState(() {
        verified = FirebaseAuth.instance.currentUser!.emailVerified;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => AppService.instance.router.open('/email-verify'),
      child: Text(
        '${verified ? 'Update' : 'Verify'} Email',
      ),
    );
  }
}
