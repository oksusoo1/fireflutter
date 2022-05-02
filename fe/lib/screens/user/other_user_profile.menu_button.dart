import 'package:extended/extended.dart';
import 'package:flutter/material.dart';

class OtherUserProfileMenuButton extends StatelessWidget {
  const OtherUserProfileMenuButton({
    required this.icon,
    required this.text,
    this.onTap,
    Key? key,
  }) : super(key: key);

  final Widget icon;
  final String text;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          icon,
          SizedBox(
            height: xsm,
            width: xsm,
            child: Divider(thickness: 2),
          ),
          Text(
            '$text',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.blueGrey[400],
            ),
          ),
        ],
      ),
    );
  }
}
