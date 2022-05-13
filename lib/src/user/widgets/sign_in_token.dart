import '../../../fireflutter.dart';
import 'package:flutter/material.dart';

class SignInToken extends StatefulWidget {
  const SignInToken({
    Key? key,
  }) : super(key: key);

  @override
  State<SignInToken> createState() => _SignInTokenState();
}

class _SignInTokenState extends State<SignInToken> with DatabaseMixin {
  String id = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    id = getRandomAlphabet();
    id += getRandomNumber(len: 3);

    await signInTokenDoc(id)
        .set({'uid': UserService.instance.uid, 'password': FunctionsApi.instance.password});

    setState(() {});
  }

  @override
  void dispose() {
    // Don't delete the token.
    // signInTokenDoc(id)
    //     .remove()
    //     .catchError((e) => print('Caught error on deleting temporary sign-in token. $e'));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Input this code to login on the website.',
        ),
        SizedBox(height: 16),
        Text(
          id,
          style: TextStyle(
            fontSize: 48,
          ),
        ),
      ],
    );
  }
}
