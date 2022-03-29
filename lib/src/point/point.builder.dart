import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PointBuilder extends StatefulWidget {
  const PointBuilder({
    Key? key,
    required this.id,
    required this.uid,
    required this.type,
    this.builder,
  }) : super(key: key);

  final String id;
  final String uid;
  final String type;
  final Function(int point, UserModel? user)? builder;

  @override
  State<PointBuilder> createState() => _PointBuilderState();
}

class _PointBuilderState extends State<PointBuilder> with DatabaseMixin {
  int point = 0;
  UserModel? user;

  @override
  void initState() {
    final ref =
        pointRef.child(widget.uid).child(widget.type + 'Create').child(widget.id).child('point');
    ref.get().then((snapshot) {
      if (snapshot.exists && snapshot.value != null) {
        setState(() {
          point = snapshot.value as int;
        });
      }
    }).catchError((e) {
      print(e);
    });

    UserService.instance.getOtherUserDoc(widget.uid).then((value) => setState(() => user = value));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder != null
        ? widget.builder!(point, user)
        : point == 0
            ? SizedBox.shrink()
            : Text(
                '${user?.displayName ?? ''} earned $point points.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              );
  }
}
