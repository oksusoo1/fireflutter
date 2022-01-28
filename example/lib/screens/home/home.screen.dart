import 'package:fe/widgets/test.user.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) ChatService.instance.countNewMessages();
    });
    // ChatService.instance.newMessages.listen((value) => debugPrint('new messages: $value'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
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
                        Text(
                          'You have logged in as ${user.email ?? user.phoneNumber}',
                        ),
                        Text('User Email: ${user.email}'),
                        UserDoc(
                          uid: user.uid,
                          builder: (UserModel u) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Profile name: ${u.name}'),
                                Text(', photo: ${u.photoUrl}'),
                              ],
                            );
                          },
                        ),
                        UserFutureDoc(
                            uid: user.uid,
                            builder: (UserModel u) {
                              return Row(
                                children: [
                                  const Text('Update '),
                                  Expanded(
                                    child: TextField(
                                      controller: TextEditingController()..text = u.name,
                                      decoration: const InputDecoration(
                                          hintText: 'Name', prefix: Text('name: ')),
                                      onChanged: (t) {
                                        UserService.instance.updateName(t).catchError(
                                            (e) => debugPrint('error on update name; $e'));
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: TextEditingController()..text = u.photoUrl,
                                      decoration: const InputDecoration(
                                        hintText: 'Photo Url',
                                        prefix: Text('photo url: '),
                                      ),
                                      onChanged: (t) {
                                        UserService.instance.updatePhotoUrl(t).catchError(
                                            (e) => debugPrint('error on update photo url; $e'));
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }),
                        ElevatedButton(
                          onPressed: () => FirebaseAuth.instance.signOut(),
                          child: const Text('Sign Out'),
                        ),
                        const EmailButton(),
                      ],
                    );
                  } else {
                    return Wrap(
                      children: [
                        ElevatedButton(
                          child: const Text('Sign-In'),
                          onPressed: () {
                            Get.toNamed('/sign-in');
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Phone Sign-In'),
                          onPressed: () {
                            Get.toNamed('/phone-sign-in');
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Phone Sign-In UI'),
                          onPressed: () {
                            Get.toNamed('/phone-sign-in-ui');
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
              const Divider(),
              const Text('Test users;'),
              Wrap(
                alignment: WrapAlignment.spaceAround,
                children: const [
                  TestUser(name: 'Apple', uid: 'uA0mjrf3FzR1FxO1rcjO7eZlGkR2'),
                  TestUser(name: 'Banana', uid: 'o0BtHX2JMiaa0SIrDJ3qhDczXDF2'),
                  TestUser(name: 'Cherry', uid: 'sys2vHyPz2fUb57qEFN2PqaegGu2'),
                  TestUser(name: 'Durian', uid: 'LLaX6TwVQSO2os2dzK3kJyTzSzs1'),
                ],
              ),
              const Divider(),
              ElevatedButton(onPressed: () => Get.toNamed('/help'), child: const Text('Help')),
              ElevatedButton(
                onPressed: () => Get.toNamed('/chat-rooms-screen'),
                child: const Text('Chat Room List'),
              ),
              const Divider(),
              TextButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Chat'),
                    ChatBadge(),
                  ],
                ),
                onPressed: () {
                  Get.toNamed('/chat-rooms-screen');
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
              const Divider(),
              const ElevatedButton(
                onPressed: getFirestoreIndexLinks,
                child: Text('Get firestore index links'),
              ),
              const Divider(),
              ElevatedButton(
                onPressed: () => Get.toNamed('/friend-map'),
                child: const Text('Friend Map'),
              ),
              ElevatedButton(
                onPressed: () => Get.toNamed('/reminder-edit'),
                child: const Text('Reminder Management Screen'),
              ),
            ],
          ),
        ),
      ),
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
      onPressed: () => Get.toNamed('/email-verify'),
      child: Text(
        '${verified ? 'Update' : 'Verify'} Email',
      ),
    );
  }
}
