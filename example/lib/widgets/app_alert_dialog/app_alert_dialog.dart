import 'package:example/services/config.dart';
import 'package:example/services/defines.dart';
import 'package:example/widgets/app_alert_dialog/app_alert_dialog_sms.dart';
import 'package:example/widgets/logo/logo.dart';
import 'package:flutter/material.dart';

class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
  }) : super(key: key);

  final String title;
  final Widget content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        /// 좁은 화면, 넓은 화면에서 다이얼로그 너비
        horizontal: MediaQuery.of(context).size.width > 600 ? 200 : 50,
      ),
      child: AlertDialog(
        titlePadding: const EdgeInsets.all(0),
        contentPadding: const EdgeInsets.all(0),
        buttonPadding: const EdgeInsets.all(0),
        insetPadding: const EdgeInsets.all(0),
        actionsPadding: const EdgeInsets.all(0),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.grey.shade200,
              child: Padding(
                padding: const EdgeInsets.all(sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.grey.shade100,
                          ],
                        ),
                        boxShadow: const [
                          BoxShadow(blurRadius: 1, color: Colors.black45),
                        ],
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Center(
                        child: SizedBox(
                          child: Logo(),
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                    spaceXsm,
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w500))
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(sm),
                child: content,
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            ),
            SmsText(
              title: 'For inquiry: ${Config.contacts.phoneNumber}',
              number: Config.contacts.inquiry,
              padding: const EdgeInsets.symmetric(vertical: sm),
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
