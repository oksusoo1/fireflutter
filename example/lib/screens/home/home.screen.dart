import 'package:fe/widgets/test.user.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      Text(
                          'You have logged in as ${snapshot.data!.email ?? snapshot.data!.phoneNumber}'),
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
          ],
        ),
      ),
    );
  }
}
