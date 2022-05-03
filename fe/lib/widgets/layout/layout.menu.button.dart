import 'package:flutter/material.dart';

class LayoutMenuButton extends StatelessWidget {
  const LayoutMenuButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  final String label;
  final Widget icon;
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
