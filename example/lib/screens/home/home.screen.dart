import 'package:example/screens/home/home.auth.dart';
import 'package:example/widgets/layout/layout.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Layout(
      isHome: true,
      title: 'Home',
      body: ListView.builder(
          itemCount: 100,
          itemBuilder: (c, i) {
            final child = Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(i.toString()),
            );

            if (i == 0) {
              return Column(
                children: [
                  const HomeAuth(),
                  child,
                ],
              );
            } else {
              return child;
            }
          }),
    );
  }
}
