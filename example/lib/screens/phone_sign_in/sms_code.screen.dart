import 'package:extended/extended.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class SmsCodeScreen extends StatefulWidget {
  const SmsCodeScreen({Key? key}) : super(key: key);

  static const String routeName = '/smsCode';

  @override
  _SmsCodeScreenState createState() => _SmsCodeScreenState();
}

class _SmsCodeScreenState extends State<SmsCodeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS code verification')),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Phone No. ${PhoneService.instance.phoneNumber}'),
            TextField(
              onChanged: (t) => PhoneService.instance.smsCode = t,
            ),
            ElevatedButton(
              onPressed: () {
                PhoneService.instance.verifySMSCode(
                  success: () async {
                    await alert('Phone sign-in success', 'You have signed-in.');
                    AppService.instance.openHome();
                    // Get.defaultDialog(
                    //     middleText: 'Phone sign-in success',
                    //     textConfirm: 'Ok',
                    //     onConfirm: () => service.back()).then(
                    //   (value) => Get.offAllNamed('/home'),
                    // );
                  },
                  error: (e) => error(e),
                  //  {
                  //   Get.defaultDialog(
                  //       middleText: e.toString(), textConfirm: 'Ok', onConfirm: () => Get.back());
                  // },
                );
              },
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: AppService.instance.back,
              child: const Text('Try again with different number'),
            )
          ],
        ),
      ),
    );
  }
}
