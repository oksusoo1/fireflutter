import 'package:example/services/global.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeAuth extends StatefulWidget {
  const HomeAuth({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  State<HomeAuth> createState() => _HomeAuthState();
}

class _HomeAuthState extends State<HomeAuth> {
  final auth = FirebaseAuth.instance;
  final phoneNumber = TextEditingController();
  final smsCode = TextEditingController();
  String step = 'input-number';

  @override
  void initState() {
    phoneNumber.text = '+1 1111 111 111';
    super.initState();
    // WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
    //   smsCodeDialog();
    // });
  }

  smsCodeDialog() async {
    await service.dialog(
      title: 'SMS code verification',
      content: TextField(
        controller: smsCode,
        decoration: InputDecoration(
          label: Text('Input SMS code'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Auth(
      signedIn: (user) => widget.child,
      signedOut: () {
        return Column(
          children: [
            TextField(
              controller: phoneNumber,
              decoration: InputDecoration(label: Text('Phone Number')),
              keyboardType: TextInputType.phone,
              readOnly: step != 'input-number',
            ),
            ElevatedButton(
              onPressed: () async {
                await auth.verifyPhoneNumber(
                  phoneNumber: phoneNumber.text,
                  verificationCompleted:
                      (PhoneAuthCredential credential) async {
                    // ANDROID ONLY!

                    // Sign the user in (or link) with the auto-generated credential
                    await auth.signInWithCredential(credential);
                  },
                  verificationFailed: (FirebaseAuthException e) {
                    if (e.code == 'invalid-phone-number') {
                      debugPrint('The provided phone number is not valid.');
                    }

                    // Handle other errors
                    service.error(e);
                  },
                  codeSent: (String verificationId, int? resendToken) async {
                    setState(() => step = 'input-code');

                    await smsCodeDialog();

                    // Create a PhoneAuthCredential with the code
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationId,
                            smsCode: smsCode.text);
                    try {
                      // Sign the user in (or link) with the credential
                      await auth.signInWithCredential(credential);
                    } catch (e) {
                      debugPrint(e.toString());
                      service.error(e);
                    }
                  },
                  codeAutoRetrievalTimeout: (String verificationId) {
                    // Auto-resolution timed out...
                    service.error('Sms code retrieval failed.');
                  },
                );
              },
              child: Text('Sign-in'),
            )
          ],
        );
      },
    );
  }
}
