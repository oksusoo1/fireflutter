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
import 'package:fe/service/app.service.dart';
import 'package:fe/service/config.dart';
// import 'package:fe/service/global.keys.dart';
import 'package:fe/widgets/sign_in.widget.dart';
import 'package:fe/widgets/test.user.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // FirebaseAuth.instance.authStateChanges().listen((user) {
    //   if (user != null) ChatService.instance.countNewMessages();
    // });
    // ChatService.instance.newMessages.listen((value) => debugPrint('new messages: $value'));
  }

  final nickname = TextEditingController();
  String uploadUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Tr('Home'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                            onFieldSubmitted: (text) => AppService.instance
                                .openSearchScreen(searchKey: text),
                            decoration: InputDecoration(hintText: 'Search ...'),
                          ),
                        ),
                        Text(
                          'You have logged in as ${user.email ?? user.phoneNumber}',
                        ),
                        Text('User Email on Auth: ${user.email}'),
                        Text(
                            'User Email on User settings: ${UserService.instance.email}'),
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
                        MyDoc(
                            builder: (u) =>
                                Text('Point: ${u.point}, Lv: ${u.level}')),
                        MyDoc(builder: (_user) {
                          if (_user.isAdmin)
                            return TextButton(
                                child: const Text(
                                  'You are an admin',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                                onPressed: AppService.instance.openAdmin);
                          else
                            return SizedBox();
                        }),
                        Wrap(
                          children: [
                            const EmailButton(),
                            ElevatedButton(
                              onPressed: AppService.instance.openProfile,
                              child: const Text('Profile'),
                            ),
                            ElevatedButton(
                              onPressed: () => AppService.instance
                                  .open(PointHistoryScreen.routeName),
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
                            AppService.instance.open(SignInWidget.routeName);
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Phone Sign-In'),
                          onPressed: () {
                            AppService.instance
                                .open(PhoneSignInScreen.routeName);
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Phone Sign-In UI'),
                          onPressed: () {
                            AppService.instance
                                .open(PhoneSignInUIScreen.routeName);
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
                      onPressed: () => AppService.instance
                              .open(HelpScreen.routeName, arguments: {
                            'when': 'Now',
                            'where': 'GimHae',
                            'who': 'Me',
                            'what': 'Working',
                          }),
                      child: const Text('Help')),
                  ElevatedButton(
                    onPressed: () =>
                        AppService.instance.open(ChatRoomsScreen.routeName),
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
                      AppService.instance.open(ChatRoomsScreen.routeName);
                    },
                  ),
                  TextButton(
                      onPressed: () async {
                        for (int i = 0; i < 10; i++) {
                          setState(() {});
                          await Future.delayed(
                              const Duration(milliseconds: 500));
                        }
                      },
                      child: const Text('setState() 10 times')),
                  const ElevatedButton(
                    onPressed: getFirestoreIndexLinks,
                    child: Text('Get firestore index links'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        AppService.instance.open(FriendMapScreen.routeName),
                    child: const Text('Friend Map'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        AppService.instance.open(ReminderEditScreen.routeName),
                    child: const Text('Reminder Management Screen'),
                  ),
                ],
              ),
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        AppService.instance.openPostList(category: 'qna'),
                    child: const Text('QnA'),
                  ),
                  // if (Platform.isAndroid)
                  //   ElevatedButton(
                  //     onPressed: () {
                  //       MessagingService.instance.sendMessage(
                  //         to: '/topics/post_qna',
                  //         data: {
                  //           "click_action": "FLUTTER_NOTIFICATION_CLICK",
                  //         },
                  //       );
                  //     },
                  //     child: const Text('Test QnA Notification'),
                  //   ),
                  ElevatedButton(
                    onPressed: () => AppService.instance
                        .openPostList(category: 'discussion'),
                    child: const Text('Discussion'),
                  ),
                  ElevatedButton(
                    onPressed: () => AppService.instance
                        .openPostList(category: 'buyandsell'),
                    child: const Text('Buy & Sell'),
                  ),

                  ElevatedButton(
                    onPressed: () =>
                        AppService.instance.open(JobListScreen.routeName),
                    child: const Text('Job'),
                  ),
                  ElevatedButton(
                    onPressed: () => AppService.instance
                        .open(JobSeekerProfileFormScreen.routeName),
                    child: const Text('Job seeker profile'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        AppService.instance.open(JobSeekerListScreen.routeName),
                    child: const Text('Job seeker list'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text('meilisearch listing'),
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed: () => AppService.instance
                        .openSearchScreen(index: 'posts', category: 'qna'),
                    child: const Text('QnA'),
                  ),
                  ElevatedButton(
                    onPressed: () => AppService.instance.openSearchScreen(
                        index: 'posts', category: 'discussion'),
                    child: const Text('Discussion'),
                  ),
                  ElevatedButton(
                    onPressed: () => AppService.instance.openSearchScreen(
                        index: 'posts', category: 'buyandsell'),
                    child: const Text('Buy & Sell'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        AppService.instance.openSearchScreen(index: 'posts'),
                    child: const Text('Search Screen'),
                  ),
                  ElevatedButton(
                    onPressed: () => AppService.instance
                        .open(AdminSearchSettingsScreen.routeName),
                    child: const Text('Search Settings'),
                  ),
                ],
              ),
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed: () => AppService.instance
                        .open(NotificationSettingScreen.routeName),
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
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed: testOnUser,
                    child: const Text('User Test'),
                  ),
                  ElevatedButton(
                    onPressed: testOnUserData,
                    child: const Text('Test User Data'),
                  ),
                  ElevatedButton(
                    onPressed: testOnForum,
                    child: const Text('Test on forum'),
                  ),
                ],
              ),
              Divider(color: Colors.blue),
              AdminButton(),
              space3xl,
            ],
          ),
        ),
      ),
    );
  }

  /// Test user profile page
  ///
  /// To use the screen state.
  /// - Add GlobalKey on the profile screen widget.
  ///   The state must be public and declared in global.keys.dart
  ///   And pass it to route declaration in main.dart
  testOnUser() async {
    // Get test service instance
    // final ts = TestService.instance;

    // // Sign out to test error
    // await FirebaseAuth.instance.signOut();

    // // openProfile() throws an error if user is not signed in.
    // await waitUntil(() => UserService.instance.user.signedOut);
    // await ts.expectFailure(AppService.instance.openProfile(),
    //     "sign in before open profile screen.");

    // /// user signed in
    // await FirebaseAuth.instance.signInWithEmailAndPassword(
    //     email: Config.testUsers['apple']!['email']!, password: '12345a');

    // /// waitl until user sign-in completes
    // await waitUntil(() => UserService.instance.user.signedIn);

    // /// Open profile screen
    // AppService.instance.openProfile();

    // /// wait
    // await Future.delayed(Duration(milliseconds: 200));

    // /// Update nickname using the profile screen state
    // final nickname = DateTime.now().toString().split('.').last;

    // /// Update nickname on screen immediately.
    // profileScreenKey.currentState?.nickname.text = nickname;

    // /// Update nickname on firestore
    // profileScreenKey.currentState?.updateNickname(nickname);

    // /// wait until nickname changes
    // await waitUntil(() => UserService.instance.user.nickname == nickname);

    // ///
    // profileScreenKey.currentState?.setState(() {});
    // ts.testSuccess('Test success on updating nickname');

    // /// Update photoUrl using the profile screen state
    // await Future.delayed(Duration(milliseconds: 200));
    // final photoUrl = 'photo url: $nickname';
    // profileScreenKey.currentState?.photoUrl.text = photoUrl;
    // profileScreenKey.currentState?.updatePhotoUrl(photoUrl);
    // await waitUntil(() => UserService.instance.user.photoUrl == photoUrl);
    // profileScreenKey.currentState?.setState(() {});
    // ts.testSuccess('Test success on updating photoUrl');

    // await Future.delayed(Duration(milliseconds: 300));

    // /// To go back to home, it must call `back()`.
    // /// If it calls `AppService.instance.openHome();`,
    // /// then `Duplicate GlobalKey detected in widget tree` error will happen
    // AppService.instance.back();
  }

  testOnUserData() async {
    // final ts = TestService.instance;
    // final settingService = UserSettingsService.instance;
    // final userService = UserService.instance;

    // ts.reset();

    // try {
    //   userService.update(field: 'abc', value: 'def');
    // } catch (e) {
    //   ts.test(e == ERROR_NOT_SUPPORTED_FIELD_ON_USER_UPDATE, 'Wrong field');
    // }

    // final timestamp = DateTime.now().millisecondsSinceEpoch;
    // await ts.expectSuccess(settingService.update({
    //   'a': 'Apple',
    //   'b': 'Banana',
    //   'timestamp': timestamp,
    // }));

    // await ts.expectSuccess(settingService.read());
    // ts.test(
    //     settingService.settings.data['timestamp'] == timestamp, 'timestamp');
  }

  testOnForum() async {
    // final tag = DateTime.now().toString().split('.').last;
    // PostService.instance.create(title: 'title-$tag', content: 'content-$tag');
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

// class ReText extends StatelessWidget {
//   const ReText({
//     Key? key,
//     required this.i,
//     required this.until,
//   }) : super(key: key);

//   final int i;
//   final int until;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text('No, $i'),
//         if (i < until)
//           ReText(
//             i: i + 1,
//             until: until,
//           )
//       ],
//     );
//   }
// }

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
          AppService.instance.openAdmin();
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
      onPressed: () => AppService.instance.open('/email-verify'),
      child: Text(
        '${verified ? 'Update' : 'Verify'} Email',
      ),
    );
  }
}
