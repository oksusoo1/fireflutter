import 'package:extended/extended.dart';
import 'package:fe/services/defines.dart';
import 'package:fe/services/global.dart';
import 'package:fe/widgets/layout/layout.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Layout(
      title: Tr(
        'Home',
        style: titleStyle,
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              spaceXs,
              NewUsers(onTap: (user) => service.router.openOtherUserProfile(user.uid)),
              spaceXs,
              QuickMenuCategories(
                  onTap: (category) => service.router.openPostList(category: category.id))
            ],
          ),
        ],
      )),
    );
  }
}
