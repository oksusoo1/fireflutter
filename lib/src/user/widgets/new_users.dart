import 'package:flutter/material.dart';
import 'package:flutterfire_ui/database.dart';
import '../../../fireflutter.dart';

class NewUsers extends StatelessWidget with DatabaseMixin {
  const NewUsers({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final Function(UserModel) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      child: FirebaseDatabaseQueryBuilder(
          query: usersRef.orderByChild('profileReady'),
          builder: (context, snapshot, _) {
            if (snapshot.isFetching) {
              return Loader();
            }

            if (snapshot.hasError) {
              // print(snapshot.error);
              return Text('Something went wrong! ${snapshot.error}');
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.docs.length,
              itemBuilder: (context, index) {
                // if we reached the end of the currently obtained items, we try to
                // obtain more items
                if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                  // Tell FirebaseDatabaseQueryBuilder to try to obtain more items.
                  // It is safe to call this function from within the build method.
                  snapshot.fetchMore();
                }

                final doc = snapshot.docs[index];

                final user = UserModel.fromJson(doc.value, doc.key!);

                // print(
                //     'user; $index, uid: ${user.uid}, profileReady: ${user.profileReady}, photoUrl: ${user.photoUrl}');

                return UserProfilePhoto(
                  key: ValueKey(user.uid),
                  margin: EdgeInsets.only(
                    left: index == 0 ? 16 : 4,
                    right: (snapshot.docs.length - 1) == index ? 16 : 4,
                  ),
                  size: 48,
                  uid: user.uid,
                  onTap: () => onTap(user),
                  emptyIconBuilder: (user) => Center(
                    child: Text(
                      (user.displayName == '' ? user.uid : user.displayName)
                          .substring(0, 1)
                          .toUpperCase(),
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}
