import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FaDuotoneIconMenu extends StatelessWidget {
  const FaDuotoneIconMenu(
    this.icon, {
    this.primaryColor,
    this.secondaryColor,
    this.left = 0,
    this.right = 0,
    this.width = 64,
    this.size,
    Key? key,
  }) : super(key: key);

  final IconDataDuotone icon;
  final Color? primaryColor;
  final Color? secondaryColor;
  final double left;
  final double right;
  final double? size;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(left: left, right: right),
          child: FaDuotoneIcon(
            icon,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            size: size,
          ),
        ),
      ),
      width: width,
    );
  }
}
