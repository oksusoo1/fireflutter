import 'package:fe/services/app.service.dart';
import 'package:fe/widgets/layout/layout.menu.button.dart';
import 'package:fe/widgets/layout/layout.menu.profile.button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Layout extends StatelessWidget {
  Layout({
    Key? key,
    required this.title,
    this.bottom,
    this.bottomLine = false,
    required this.body,
    this.actions,
    this.backgroundColor = Colors.white,
    this.appBarBackgroundColor = Colors.white,
    this.backButton = false,
    this.backButtonColor = Colors.black,
  }) : super(key: key);

  final Widget title;
  final Widget body;
  final PreferredSizeWidget? bottom;
  final bool bottomLine;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color appBarBackgroundColor;
  final bool backButton;
  final Color backButtonColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              leading: backButton
                  ? BackButton(
                      color: backButtonColor,
                      onPressed: AppService.instance.router.back,
                    )
                  : null,
              pinned: bottom == null ? false : true,
              floating: true,
              backgroundColor: appBarBackgroundColor,
              title: title,
              bottom: bottom,
              actions: actions,
              shape: bottomLine ? Border(bottom: BorderSide(color: Colors.grey.shade300)) : null,
            ),
          ];
        },
        body: body,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60,
          decoration: BoxDecoration(border: Border(top: BorderSide())),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            LayoutMenuButton(
              label: 'Forum',
              icon: FaIcon(FontAwesomeIcons.lightCommentAlt),
              onTap: () => AppService.instance.router.openHome(popAll: true),
            ),
            LayoutMenuButton(
              label: 'Attraction',
              icon: FaIcon(FontAwesomeIcons.lightTrees),
              onTap: AppService.instance.router.openAbout,
            ),
            LayoutMenuButton(
              label: 'Job',
              icon: FaIcon(FontAwesomeIcons.lightBriefcase),
              onTap: () => AppService.instance.router.openPostList(popAll: true),
            ),
            LayoutMenuButton(
              label: 'Meetup',
              icon: FaIcon(FontAwesomeIcons.lightUsers),
              onTap: () => AppService.instance.router.openPostList(popAll: true),
            ),
            LayoutMenuButton(
              label: 'Photo',
              icon: FaIcon(FontAwesomeIcons.lightCamera),
              onTap: () => AppService.instance.router.openPostList(popAll: true),
            ),
            LayoutMenuProfileButton(),
            LayoutMenuButton(
              label: 'Mneu',
              icon: FaIcon(FontAwesomeIcons.lightBars),
              onTap: () => AppService.instance.router.openMenu(popAll: true),
            ),
          ]),
        ),
      ),
    );
  }
}
