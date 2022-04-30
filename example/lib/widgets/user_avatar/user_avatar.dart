import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class UserPhoto extends StatelessWidget {
  const UserPhoto({
    Key? key,
    required this.url,
    this.progress = 0,
    this.width = 100,
    this.height = 100,
  }) : super(key: key);

  final String url;
  final double progress;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          url == ''
              ? Center(
                  child: Icon(
                    Icons.person,
                    size: 64,
                  ),
                )
              : ClipOval(
                  child: UploadedImage(
                    url: url,
                    width: width,
                    height: height,
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
