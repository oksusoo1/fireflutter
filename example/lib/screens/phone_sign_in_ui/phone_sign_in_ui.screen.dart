import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:get/get.dart';

class PhoneSignInUIScreen extends StatefulWidget {
  const PhoneSignInUIScreen({Key? key}) : super(key: key);

  @override
  _PhoneSignInUIScreenState createState() => _PhoneSignInUIScreenState();
}

class _PhoneSignInUIScreenState extends State<PhoneSignInUIScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone sign in UI'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PhoneNumberInput(
              selectBuilder: () => const Text('Select Country Dial Code'),
              selectedBuilder: (CountryCode code) {
                return Row(
                  children: [
                    Text(code.dialCode.toString()),
                    Image.asset(
                      code.flagUri!,
                      package: 'country_code_picker',
                      width: 30.0,
                    ),
                    Text(code.name ?? ''),
                  ],
                );
              },
              codeSent: (id) => Get.toNamed('/sms-code-ui'),
              success: () => Get.defaultDialog(
                middleText: 'Phone Sign In Success',
                textConfirm: 'Ok',
                onConfirm: Get.back,
              ).then(
                (value) => Get.offAllNamed('/home'),
              ),
              error: (e) => Get.defaultDialog(
                middleText: e.toString(),
                textConfirm: 'Ok',
                onConfirm: Get.back,
              ),
              codeAutoRetrievalTimeout: (x) => Get.defaultDialog(
                middleText: 'Failed on sending SMS code. Please retry.',
                textConfirm: 'Ok',
                onConfirm: Get.back,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
