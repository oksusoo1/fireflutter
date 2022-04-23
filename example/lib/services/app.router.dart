import 'package:example/screens/about/about.screen.dart';
import 'package:example/screens/home/home.screen.dart';
import 'package:example/screens/menu/menu.screen.dart';
import 'package:example/screens/profile/profile.edit.screen.dart';
import 'package:example/screens/profile/profile.screen.dart';
import 'package:example/services/global.dart';
import 'package:flutter/material.dart';

typedef RouteFunction = Widget Function(BuildContext, Map);

final Map<String, RouteFunction> _routes = {
  HomeScreen.routeName: (context, arguments) => const HomeScreen(),
  AboutScreen.routeName: (context, arguments) => const AboutScreen(),
  MenuScreen.routeName: (context, arguments) => const MenuScreen(),
  ProfileScreen.routeName: (context, arguments) => const ProfileScreen(),
  ProfileEditScreen.routeName: (context, arguments) =>
      const ProfileEditScreen(),
};

class NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationMaterialPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
            builder: builder,
            maintainState: maintainState,
            settings: settings,
            fullscreenDialog: fullscreenDialog);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}

/// AppRouter
///
/// App can handle route event handler like `didPop()` using NavigatorObserver.
class AppRouter extends NavigatorObserver {
  static AppRouter? _instance;
  static AppRouter get instance => _instance ?? (_instance = AppRouter());
  AppRouter() {
    debugPrint('--> AppRouter::constructor');
  }

  BuildContext get context => globalNavigatorKey.currentContext!;

  /// Connect this to onGenerateRoute of MaterialApp
  static Route<dynamic> onGenerateRoute(settings) {
    final String name = settings.name;

    /// 그리고, MaterialApp 의 onGenerateRoute() 의 결과로 리턴 할 route 작성
    final route = NoAnimationMaterialPageRoute(
      builder: (c) {
        return _routes[name]!(
          c,
          ((settings.arguments ?? {}) as Map),
        );
      },

      /// 중요; 아래와 같이 settings 값을 전달해야,
      /// didPush(), didPop() 등의 이벤트 핸들러에서
      /// `route.settings.name` 와 같이 settings 를 사용 할 수 있다..
      settings: settings,
    );

    ///
    return route;
  }

  /// Open a screen.
  ///
  /// If [popAll] is set to true, then it removes all the screen in nav stack.
  ///
  // Future? open(String routeName,
  //     {Map<String, dynamic>? arguments, popAll = false, off = false, preventDuplicates = true}) {
  //   global.routeName.value = routeName;
  //   if (popAll) {
  //     return Get.popAllNamed(routeName, arguments: arguments);
  //   } else if (off) {
  //     return Get.offNamed(routeName, arguments: arguments, preventDuplicates: preventDuplicates);
  //   } else {
  //     return Get.toNamed(routeName, arguments: arguments, preventDuplicates: preventDuplicates);
  //   }
  // }

  /// If [pop] is set to true, then it will pop current page
  ///   (which has name, Not drawer, and not limited to dialogs)
  ///   and put a new screen.
  /// If [popAll] is true, then it will remove all screen in route stack and put a new screen.
  ///   Use [popAll] when the app goes to home screen.
  Future<dynamic> open(
    String routeName, {
    Map? arguments,
    bool pop = false,
    bool popAll = false,
    bool preventDuplicate = true,
  }) {
    if (pop) {
      return Navigator.of(context).popAndPushNamed(
        routeName,
        arguments: arguments,
      );
    } else if (popAll) {
      return Navigator.of(context).pushNamedAndRemoveUntil(
        routeName,
        (Route<dynamic> route) => false,
        arguments: arguments,
      );
    } else {
      return Navigator.pushNamed(
        context,
        routeName,
        arguments: arguments,
      );
    }
  }

  /// Return to previous page
  void back([dynamic data]) {
    Navigator.pop(globalNavigatorKey.currentContext!, data);
  }

  Future openHome() {
    return open(HomeScreen.routeName, popAll: true);
  }

  Future openAbout() {
    return open(AboutScreen.routeName, popAll: true);
  }

  Future openMenu() {
    return open(MenuScreen.routeName, popAll: true);
  }

  Future openProfile() {
    return open(ProfileScreen.routeName, popAll: true);
  }

  Future openProfileEdit() {
    return open(ProfileEditScreen.routeName);
  }
}
