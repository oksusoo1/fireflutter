import 'package:extended/extended.dart';
import 'package:fe/screens/phone_sign_in_ui/sms_code_ui.screen.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';

class PhoneSignInUIScreen extends StatefulWidget {
  const PhoneSignInUIScreen({Key? key}) : super(key: key);

  static const String routeName = '/phoneSignInUi';
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
            const Text(
              'Phone Sign In',
              style: TextStyle(color: Colors.blue, fontSize: 24),
            ),
            const SizedBox(height: 24),
            const Text('1. Select your country dial code'),
            const SizedBox(height: 10),

            /// You can also do design with UI builders.
            ///
            ///
            PhoneNumberInput(
              /// [countryButtonBuilder] is the button design to select country dial code.
              countryButtonBuilder: () => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'Select Country Dial Code',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),

              /// [countrySelectedBuilder] is the design to display when country dial
              /// code is selected.
              /// It uses [country_code_picker](https://pub.dev/packages/country_code_picker)
              /// package to choose country dial code. And CountryCode will be
              /// passed on selectedBuilder
              ///
              countrySelectedBuilder: (CountryCode code) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Text(code.dialCode.toString()),
                      const SizedBox(width: 10),
                      Image.asset(
                        code.flagUri!,
                        package: 'country_code_picker',
                        width: 30.0,
                      ),
                      const SizedBox(width: 10),
                      Text(code.name ?? ''),
                    ],
                  ),
                );
              },

              /// [inputTitle] is the widget to be shown on the input box when input box is visible.
              ///
              inputTitle: Column(
                children: const [
                  SizedBox(height: 32),
                  Text('2. Enter your phone number'),
                  SizedBox(height: 10),
                ],
              ),

              /// [phoneNumberContainerBuilder] is the wrapper for phone number
              /// input line. User `Container` or any widget to add custom design.
              phoneNumberContainerBuilder: (child) => Container(
                child: child,
                padding: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              ///
              /// [dialCodeStyle] is the dial code text style beside the input box.
              ///
              dialCodeStyle: const TextStyle(fontSize: 32),

              /// [phoneNumberInputDecoration] is the phone number input field decoration.
              phoneNumberInputDecoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(8),
              ),

              /// [phoneNumberInputTextStyle] is the text style of phone number.
              ///
              phoneNumberInputTextStyle: const TextStyle(fontSize: 32),
              submitTitle: Column(
                children: const [
                  SizedBox(height: 32),
                  Text('3. Submit to verify'),
                  SizedBox(height: 8),
                ],
              ),

              /// [submitButton] is the submit button. It's not a builder function.
              ///
              submitButton: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'Verify phone number',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              /// [codeSent] handler will be invoked on sms verification code had
              /// been sent. You may redirect the user to sms code input screen.
              codeSent: (id) =>
                  AppService.instance.open(SmsCodeUIScreen.routeName),

              /// [success] handler will be invoked only on Android devices that
              /// support automatic SMS code resolution.
              success: () => alert(
                'Phone Sign-in Success',
                'You have signed in',
              ).then(
                (value) => AppService.instance.openHome(),
              ),
              // Get.defaultDialog(
              //   middleText: 'Phone Sign In Success',
              //   textConfirm: 'Ok',
              //   onConfirm: Get.back,
              // ).then(
              //   (value) => Get.offAllNamed('/home'),
              // ),

              /// error handler
              error: (e) =>
                  error(e), //.then((value) => AppService.instance.back()),
              // Get.defaultDialog(
              //   middleText: e.toString(),
              //   textConfirm: 'Ok',
              //   onConfirm: Get.back,
              // ),

              /// [codeAutoRetrievalTimeout] handler will be invoked when code
              /// auto retreival time is over.
              codeAutoRetrievalTimeout: (x) => alert(
                'Timeout',
                'Failed on sending SMS code. Please retry.',
              ).then(
                (value) => AppService.instance.back(),
              ),

              //  Get.defaultDialog(
              //   middleText: 'Failed on sending SMS code. Please retry.',
              //   textConfirm: 'Ok',
              //   onConfirm: Get.back,
              // ),

              /// [progress] is the widget to show while verification is in progress.
              progress: const CircularProgressIndicator.adaptive(),
            ),
          ],
        ),
      ),
    );
  }
}
