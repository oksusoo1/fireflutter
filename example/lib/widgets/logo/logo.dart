import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key, this.size = 64}) : super(key: key);

  final double size;
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.jpg',
      width: size,
      height: size,
    );
  }
}
