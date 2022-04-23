import 'package:example/services/global.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MenuItem {
  Widget icon;
  Function() onTap;

  MenuItem({required this.icon, required this.onTap});
}

class Layout extends StatefulWidget {
  const Layout({
    Key? key,
    this.isHome = false,
    required this.title,
    this.bottom,
    required this.body,
    this.actions,
    this.backgroundColor = Colors.grey,
    this.appBarBackgroundColor = Colors.white,
  }) : super(key: key);

  final bool isHome;
  final Widget title;
  final Widget body;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color appBarBackgroundColor;

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> with SingleTickerProviderStateMixin {
  late Map<String, MenuItem> menus;

  final player = AudioPlayer();
  @override
  void initState() {
    super.initState();
    menus = {
      'Home': MenuItem(
          icon: const Icon(Icons.home), onTap: service.router.openHome),
      'About': MenuItem(
          icon: const Icon(Icons.info), onTap: service.router.openAbout),
      'Forum': MenuItem(
          icon: const Icon(Icons.chat_bubble), onTap: service.router.openHome),
      'Meetup': MenuItem(
          icon: const Icon(Icons.access_time), onTap: service.router.openHome),
      'Watch': MenuItem(
          icon: const Icon(Icons.zoom_in), onTap: service.router.openHome),
      'Profile': MenuItem(
          icon: const Icon(Icons.person), onTap: service.router.openProfile),
      'Menu': MenuItem(
          icon: const Icon(Icons.menu), onTap: service.router.openMenu),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: widget.bottom == null ? false : true,
              floating: true,
              // snap: true,
              backgroundColor: widget.appBarBackgroundColor,
              title: widget.title,
              bottom: widget.bottom,
              actions: widget.actions,
            ),
          ];
        },
        body: widget.body,
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.yellowAccent.shade700,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: menus.entries
              .map(
                (e) => GestureDetector(
                  onTap: () async {
                    // call this method when desired

                    // await player.setSource(AssetSource('sounds/coin.wav'));
                    player.play(AssetSource('click.mp3'));

                    e.value.onTap();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      e.value.icon,
                      Text(
                        e.key,
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
