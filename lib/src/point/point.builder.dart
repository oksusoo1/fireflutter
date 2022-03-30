import 'package:firebase_database/firebase_database.dart';
import '../../fireflutter.dart';
import 'package:flutter/material.dart';

class PointBuilder extends StatelessWidget with DatabaseMixin {
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
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
        stream: pointRef.child(uid).child(type + 'Create').child(id).child('point').onValue,
        builder: (c, snapshotPointData) {
          if (snapshotPointData.hasData) {
            final DatabaseEvent event = snapshotPointData.data!;
            final int point = (event.snapshot.value ?? 0) as int;
            return FutureBuilder(
                future: UserService.instance.getOtherUserDoc(uid),
                builder: ((cc, snapshotUserData) {
                  if (snapshotUserData.hasData) {
                    final UserModel user = snapshotUserData.data as UserModel;
                    return builder != null
                        ? builder!(point, user)
                        : point == 0
                            ? SizedBox.shrink()
                            : Text(
                                '* ${user.displayName} earned $point points.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                  } else {
                    return SizedBox.shrink();
                  }
                }));
          } else {
            return SizedBox.shrink();
          }
        });
  }
}
