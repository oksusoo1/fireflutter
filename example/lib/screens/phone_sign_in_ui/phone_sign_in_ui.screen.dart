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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// You can add your custom design here.
            ///
            const Text('1. Select your country dial code'),

            /// You can also do design with UI builders.
            ///
            /// [countryButtonBuilder] is the button design to select country dial code.
            ///
            /// [countrySelectedBuilder] is the design to display when country dial
            /// code is selected.
            /// It uses [country_code_picker](https://pub.dev/packages/country_code_picker)
            /// package to choose country dial code. And CountryCode will be
            /// passed on selectedBuilder
            ///
            /// [codeSent] handler will be invoked on sms verification code had
            /// been sent. You may redirect the user to sms code input screen.
            ///
            /// [success] handler will be invoked only on Android devices that
            /// support automatic SMS code resolution.
            ///
            /// [codeAutoRetrievalTimeout] handler will be invoked when code
            /// auto retreival time is over.
            ///
            ///
            /// [dialCodeStyle] is the dial code text style beside the input box.
            ///
            /// [phoneNumberInputDecoration] is the phone number input field decoration.
            /// [phoneNumberInputTextStyle] is the text style of phone number.
            ///
            /// [submitButton] is the submit button. It's not a builder function.
            ///
            /// [inputTitle] is the widget to be shown on the input box when input box is visible.
            ///
            PhoneNumberInput(
              countryButtonBuilder: () => Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Text('Select Country Dial Code')),
              countrySelectedBuilder: (CountryCode code) {
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
              inputTitle: const Text('Please enter your phone number'),
              dialCodeStyle: const TextStyle(fontSize: 32),
              phoneNumberInputDecoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
              ),
              phoneNumberInputTextStyle: const TextStyle(fontSize: 32),
              submitTitle: const Text('Submit your phone number to verify'),
              submitButton: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: const Text(
                  'Verify phone number',
                  style: TextStyle(color: Colors.white),
                ),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
              ),
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
