import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

/// UserProfilePhoto
///
/// Display user profile avatar
/// If [uid] is null, then it uses [MyDoc] to display signed-in user's profile
/// photo and it will render again on profile photo change.
/// if [uid] is set, then it uses [UserDoc] to display other user's profile
/// photo and it will not render again even if the user's photo changes.
///
/// Use it with [uid] as null on displaying sign-in user's photo.
class UserProfilePhoto extends StatelessWidget {
  const UserProfilePhoto({
    this.uid,
    this.size = 40,
    this.iconSize = 24,
    this.onTap,
    this.boxShadow = const BoxShadow(color: Colors.white, blurRadius: 1.0, spreadRadius: 1.0),
    this.padding,
    this.margin,
    Key? key,
  }) : super(key: key);

  final String? uid;
  final double size;
  final double iconSize;
  final Function()? onTap;
  final BoxShadow boxShadow;

  final EdgeInsets? padding;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final builder = (UserModel user) => Container(
          padding: padding,
          margin: margin,
          child: ClipOval(
            child: user.photoUrl != ''
                ? UploadedImage(
                    url: user.photoUrl,
                    width: size,
                    height: size,
                  )
                : Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 111, 111, 111),
                    size: iconSize,
                  ),
          ),
          constraints: BoxConstraints(
            minWidth: size,
            minHeight: size,
            maxWidth: size,
            maxHeight: size,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: user.photoUrl == '' ? Colors.grey.shade300 : Colors.white,
            boxShadow: [boxShadow],
          ),
        );

    final child = uid == null
        ? MyDoc(builder: builder)
        : UserDoc(
            uid: uid!,
            builder: builder,
          );
    if (onTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}
