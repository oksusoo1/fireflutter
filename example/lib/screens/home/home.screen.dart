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
    ChatService.instance.newMessages.listen((value) => print('new messages: $value'));
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
                        Text('You have logged in as ${user.email ?? user.phoneNumber}'),
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
                                        UserService.instance
                                            .updateName(t)
                                            .catchError((e) => print('error on update name; $e'));
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: TextEditingController()..text = u.photoUrl,
                                      decoration: const InputDecoration(
                                          hintText: 'Photo Url', prefix: Text('photo url: ')),
                                      onChanged: (t) {
                                        UserService.instance.updatePhotoUrl(t).catchError(
                                            (e) => print('error on update photo url; $e'));
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }),
                        ElevatedButton(
                            onPressed: () => FirebaseAuth.instance.signOut(),
                            child: const Text('Sign Out')),
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
                  TestUser(name: 'Dragon', uid: 'LLaX6TwVQSO2os2dzK3kJyTzSzs1'),
                ],
              ),
              const Divider(),
              ElevatedButton(onPressed: () => Get.toNamed('/help'), child: const Text('Help')),
              ElevatedButton(
                onPressed: () => Get.toNamed('/chat-rooms-screen'),
                child: const Text('Chat Room List'),
              ),
              const ChatBadge(),
              const Divider(),
              ElevatedButton(
                  onPressed: () => Get.toNamed('/friend-map'), child: const Text('Friend Map'))
            ],
          ),
        ),
      ),
    );
  }
}
