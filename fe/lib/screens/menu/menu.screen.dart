import 'package:firebase_auth/firebase_auth.dart';
import 'package:extended/extended.dart';
import 'package:fe/screens/phone_sign_in/phone_sign_in.screen.dart';
import 'package:fe/screens/phone_sign_in_ui/phone_sign_in_ui.screen.dart';
import 'package:fe/screens/point_history/point_history.screen.dart';
import 'package:fe/screens/test/test.screen.dart';
import 'package:fe/services/app.service.dart';
import 'package:fe/services/global.dart';
import 'package:fe/widgets/layout/layout.dart';
import 'package:fe/widgets/sign_in.widget.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    Key? key,
  }) : super(key: key);

  static const String routeName = '/menu';
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Layout(
      title: Text('Menu'),
      body: Column(
        children: [
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
                          onPressed: () =>
                              UserService.instance.signOut(), //  FirebaseAuth.instance.signOut(),
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
          ElevatedButton(
            onPressed: service.router.openChatRooms,
            child: const Text('Chat Room List'),
          ),
          ElevatedButton(
            onPressed: () => AppService.instance.router.open(PhoneSignInScreen.routeName),
            child: const Text('Phone Sign-In'),
          ),
          ElevatedButton(
            onPressed: service.router.openTest,
            child: const Text('Test Screen'),
          ),
        ],
      ),
    );
  }
}
