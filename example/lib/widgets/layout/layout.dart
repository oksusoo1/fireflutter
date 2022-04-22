import 'package:example/services/global.dart';
import 'package:flutter/material.dart';

class MenuItem {
  Widget icon;
  Function() onTap;

  MenuItem({required this.icon, required this.onTap});
}

class Layout extends StatefulWidget {
  const Layout({
    Key? key,
    this.isHome = false,
    this.title = '',
    required this.body,
  }) : super(key: key);

  final bool isHome;
  final String title;
  final Widget body;

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> with SingleTickerProviderStateMixin {
  late Map<String, MenuItem> menus;

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
          icon: const Icon(Icons.person), onTap: service.router.openHome),
      'Menu': MenuItem(
          icon: const Icon(Icons.menu), onTap: service.router.openMenu),
    };
  }

  @override
  Widget build(BuildContext context) {
    /// TEST
    // Timer(Duration(milliseconds: 500), () => _scaffoldKey.currentState!.openEndDrawer());
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              // snap: true,
              title: Text(widget.title),
              bottom: const TabBar(
                indicatorColor: Colors.red,
                indicatorWeight: 5,
                tabs: [
                  Tab(
                    icon: Icon(Icons.home),
                    text: 'Home',
                  ),
                  Tab(
                    icon: Icon(Icons.list_alt),
                    text: 'Feed',
                  ),
                  Tab(
                    icon: Icon(Icons.person),
                    text: 'Profile',
                  ),
                  Tab(
                    icon: Icon(Icons.settings),
                    text: 'Settings',
                  ),
                ],
              ),
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
              .map((e) => GestureDetector(
                    onTap: e.value.onTap,
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
                  ))
              .toList(),
        ),
      ),
    );
  }
}
