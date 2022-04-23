import 'package:example/services/defines.dart';
import 'package:flutter/material.dart';

class HomeMenu extends StatefulWidget with PreferredSizeWidget {
  const HomeMenu({Key? key, required this.height}) : super(key: key);
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        children: const [
          spaceSm,
          Text('Your Feed'),
          spaceXs,
          Text('Favorites'),
          spaceXs,
          Text('Recent'),
          Spacer(),
          Icon(Icons.tune),
        ],
      ),
    );
  }
}
