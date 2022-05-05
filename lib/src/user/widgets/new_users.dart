import 'package:flutter/material.dart';
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
      child: FutureBuilder<List<UserModel>>(
        future: UserService.instance.getNewUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) return SizedBox.shrink();
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          }

          List<UserModel> users = snapshot.data!;

          print('building new user list with: ${users.length} users');

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              // print(
              //     'user; $index, uid: ${user.uid}, profileReady: ${user.profileReady}, photoUrl: ${user.photoUrl}');

              return UserProfilePhoto(
                key: ValueKey(user.uid),
                margin: EdgeInsets.only(
                  left: index == 0 ? 16 : 4,
                  right: (users.length - 1) == index ? 16 : 4,
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
        },
      ),
    );
  }
}
