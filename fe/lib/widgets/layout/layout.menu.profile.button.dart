import 'package:fe/services/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LayoutMenuProfileButton extends StatefulWidget {
  const LayoutMenuProfileButton({Key? key}) : super(key: key);

  @override
  State<LayoutMenuProfileButton> createState() => _LayoutMenuProfileButtonState();
}

class _LayoutMenuProfileButtonState extends State<LayoutMenuProfileButton> {
  @override
  Widget build(BuildContext context) {
    return MyDoc(builder: (my) {
      if (my.signedOut)
        return GestureDetector(
          onTap: () => AppService.instance.router.openPhoneSignInUI(popAll: true),
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.lightUserLock),
              SizedBox(height: 2),
              Text(
                'Sign in',
                style: const TextStyle(
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      return GestureDetector(
        onTap: () => AppService.instance.router.openProfile(popAll: true),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChatBadge(
              builder: (Widget? badge) {
                if (badge == null) {
                  return UserProfilePhoto(size: 26);
                } else {
                  return Container(
                    width: 32,
                    child: Stack(
                      children: [
                        UserProfilePhoto(
                          size: 26,
                        ),
                        Positioned(
                          child: badge,
                          top: -3,
                          right: 0,
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 2),
            Text(
              'Profile',
              style: const TextStyle(
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    });
  }
}
