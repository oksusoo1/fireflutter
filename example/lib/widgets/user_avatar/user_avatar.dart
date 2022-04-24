import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar(
      {Key? key,
      required this.url,
      required this.progress,
      this.width = 100,
      this.height = 100})
      : super(key: key);

  final String url;
  final double progress;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.person,
              size: 64,
            ),
          ),
          SizedBox(
            width: width,
            height: height,
            child: CircularProgressIndicator(
              value: progress,
            ),
          )
        ],
      ),
    );
  }
}
