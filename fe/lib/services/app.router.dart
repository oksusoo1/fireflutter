// import 'package:fe/screens/chat/chat.room.screen.dart';

import 'package:fe/screens/about/about.screen.dart';
import 'package:fe/screens/admin/admin.screen.dart';
import 'package:fe/screens/admin/admin.search_settings.screen.dart';
import 'package:fe/screens/admin/category.screen.dart';
import 'package:fe/screens/admin/category_group.screen.dart';
import 'package:fe/screens/admin/report.post.management.screen.dart';
import 'package:fe/screens/admin/report.screen.dart';
import 'package:fe/screens/admin/send.push.notification.dart';
import 'package:fe/screens/admin/translatoins.screen.dart';
import 'package:fe/screens/forum/post.list.screen.dart';
import 'package:fe/screens/forum/post.form.screen.dart';
import 'package:fe/screens/forum/post.view.screen.dart';
import 'package:fe/screens/job/job.edit.screen.dart';
import 'package:fe/screens/job/job.list.screen.dart';
import 'package:fe/screens/job/job.seeker.profile.screen.dart';
import 'package:fe/screens/job/job.seeker.list.screen.dart';
import 'package:fe/screens/job/job.seeker.profile.view.screen.dart';
import 'package:fe/screens/job/job.view.screen.dart';
import 'package:fe/screens/menu/menu.screen.dart';
import 'package:fe/screens/point_history/point_history.screen.dart';
import 'package:fe/screens/search/search.screen.dart';
import 'package:fe/screens/setting/notification.setting.dart';
import 'package:fe/screens/test/test.screen.dart';
import 'package:fe/screens/unit_test/unit_test.screen.dart';
import 'package:fe/screens/user/other_user_profile.screen.dart';
import 'package:fe/services/app.service.dart';
import 'package:fe/screens/chat/chat.room.screen.dart';
import 'package:fe/screens/chat/chat.rooms.blocked.screen.dart';
import 'package:fe/screens/chat/chat.rooms.screen.dart';
import 'package:fe/screens/email_verification/email_verification.screen.dart';
import 'package:fe/screens/friend_map/friend_map.screen.dart';
import 'package:fe/screens/help/help.screen.dart';
import 'package:fe/screens/home/home.screen.dart';
import 'package:fe/screens/phone_sign_in/phone_sign_in.screen.dart';
import 'package:fe/screens/phone_sign_in/sms_code.screen.dart';
import 'package:fe/screens/phone_sign_in_ui/phone_sign_in_ui.screen.dart';
import 'package:fe/screens/phone_sign_in_ui/sms_code_ui.screen.dart';
import 'package:fe/screens/profile/profile.screen.dart';
import 'package:fe/screens/reminder/reminder.edit.screen.dart';
import 'package:fe/services/global.dart';
import 'package:fe/widgets/sign_in.widget.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

typedef RouteFunction = Widget Function(BuildContext, Map);
final Map<String, RouteFunction> appRoutes = {
  HomeScreen.routeName: (context, arguments) => const HomeScreen(),
  MenuScreen.routeName: (context, arguments) => const MenuScreen(),
  AboutScreen.routeName: (context, arguments) => const AboutScreen(),
  SignInWidget.routeName: (context, arguments) => const SignInWidget(),
  PhoneSignInScreen.routeName: (context, arguments) => const PhoneSignInScreen(),
  SmsCodeScreen.routeName: (context, arguments) => const SmsCodeScreen(),
  PhoneSignInUIScreen.routeName: (context, arguments) => const PhoneSignInUIScreen(),
  SmsCodeUIScreen.routeName: (context, arguments) => const SmsCodeUIScreen(),
  HelpScreen.routeName: (context, arguments) => HelpScreen(arguments: arguments),
  ProfileScreen.routeName: (context, arguments) => ProfileScreen(key: profileScreenKey),
  PostListScreen.routeName: (context, arguments) => PostListScreen(arguments: arguments),
  PostFormScreen.routeName: (context, arguments) => PostFormScreen(arguments: arguments),
  AdminScreen.routeName: (context, arguments) => AdminScreen(),
  NotificationSettingScreen.routeName: (context, arguments) => NotificationSettingScreen(),
  ReportPostManagementScreen.routeName: (context, arguments) =>
      ReportPostManagementScreen(arguments: arguments),
  CategoryScreen.routeName: (context, arguments) => CategoryScreen(),
  ChatRoomScreen.routeName: (context, arguments) => ChatRoomScreen(arguments: arguments),
  ChatRoomsScreen.routeName: (context, arguments) => ChatRoomsScreen(),
  ChatRoomsBlockedScreen.routeName: (context, arguments) => ChatRoomsBlockedScreen(),
  FriendMapScreen.routeName: (context, arguments) => FriendMapScreen(arguments: arguments),
  ReminderEditScreen.routeName: (context, arguments) => ReminderEditScreen(),
  ReportScreen.routeName: (context, arguments) => ReportScreen(arguments: arguments),
  EmailVerificationScreen.routeName: (context, arguments) => EmailVerificationScreen(),
  TranslationsScreen.routeName: (context, arguments) => TranslationsScreen(),
  PostListScreenV2.routeName: (context, arguments) => PostListScreenV2(arguments: arguments),
  AdminSearchSettingsScreen.routeName: (context, arguments) => AdminSearchSettingsScreen(),
  PushNotificationScreen.routeName: (context, arguments) =>
      PushNotificationScreen(arguments: arguments),
  PostViewScreen.routeName: (context, arguments) => PostViewScreen(arguments: arguments),
  JobListScreen.routeName: (context, arguments) => JobListScreen(arguments: arguments),
  JobEditScreen.routeName: (context, arguments) => JobEditScreen(arguments: arguments),
  JobViewScreen.routeName: (context, arguments) => JobViewScreen(arguments: arguments),
  PointHistoryScreen.routeName: (context, arguments) => PointHistoryScreen(),
  CategoryGroupScreen.routeName: (context, arguments) => CategoryGroupScreen(),
  JobSeekerProfileFormScreen.routeName: (context, arguments) => JobSeekerProfileFormScreen(),
  JobSeekerProfileViewScreen.routeName: (context, arguments) =>
      JobSeekerProfileViewScreen(arguments: arguments),
  JobSeekerListScreen.routeName: (context, arguments) => JobSeekerListScreen(),
  UnitTestScreen.routeName: (context, arguments) => UnitTestScreen(),
  TestScreen.routeName: (context, arguments) => TestScreen(),

  /// --- new refactoring
  OtherUserProfileScreen.routeName: (context, arguments) =>
      OtherUserProfileScreen(arguments: arguments),
};

/// NoAnimationMaterialPageRoute is for removing page transition.
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

class AppRouter extends NavigatorObserver {
  static AppRouter? _instance;
  static AppRouter get instance => _instance ?? (_instance = AppRouter());

  AppRouter() {
    debugPrint('--> AppRouter::constructor();');
  }

  BuildContext get context => globalNavigatorKey.currentContext!;

  static Map<String, Route> routeStack = {};
  String get currentRouteName {
    return AppRouter.routeStack.keys.last;
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    String name = settings.name!;
    if (routeStack[name] != null) {
      Navigator.of(AppRouter.instance.context).removeRoute(routeStack[name]!);
      routeStack.remove(name);
    }

    /// 그리고, MaterialApp 의 onGenerateRoute() 의 결과로 리턴 할 route 작성
    final route = NoAnimationMaterialPageRoute(
      builder: (c) {
        return appRoutes[name]!(
          c,
          ((settings.arguments ?? {}) as Map),
        );
      },

      /// 중요; 아래와 같이 settings 값을 전달해야,
      /// didPush(), didPop() 등의 이벤트 핸들러에서
      /// `route.settings.name` 와 같이 settings 를 사용 할 수 있다..
      settings: settings,
    );

    routeStack[name] = route;
    debugPrint('push screen; -- $name');
    debugPrint(routeStack.keys.toString());
    return route;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    String routeName = route.settings.name ?? '';
    AppRouter.routeStack.remove(routeName);
    print('pop screen; -- $routeName');
    print(routeStack.keys);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('----> this happend didRemove');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    print('----> this happend didReplace');
  }

  void back([dynamic data]) {
    AppService.instance.pageTransitionSound();
    Navigator.pop(globalNavigatorKey.currentContext!, data);
  }

  Future<void> open(
    String routeName, {
    Map? arguments,
    bool popAll = false,
  }) {
    AppService.instance.pageTransitionSound();

    if (popAll) {
      AppRouter.routeStack = {};
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

  Future<void> openProfile() async {
    if (UserService.instance.user.signedOut) throw ERROR_SIGN_IN;
    return open(ProfileScreen.routeName);
  }

  Future<void> openHome() async {
    return open(HomeScreen.routeName);
  }

  Future<void> openAbout() async {
    return open(AboutScreen.routeName);
  }

  Future openPostView({PostModel? post, String? id}) {
    return open(PostViewScreen.routeName, arguments: {'post': post, 'id': id});
  }

  Future<void> openTranslations() {
    return open(TranslationsScreen.routeName);
  }

  Future<void> openPostList({String? category}) async {
    return open(PostListScreen.routeName, arguments: {'category': category});
  }

  Future<void> openSearchScreen({
    String? index,
    String? category,
    String? uid,
    String? searchKey,
  }) async {
    return open(PostListScreenV2.routeName, arguments: {
      'index': index,
      'category': category,
      'uid': uid,
      'searchKey': searchKey,
    });
  }

  /// Returns post id of newly created post.
  Future<dynamic> openPostForm({String? category, PostModel? post}) async {
    return open(PostFormScreen.routeName, arguments: {
      'category': category,
      'post': post,
    });
  }

  Future<void> openAdmin() async {
    return open(AdminScreen.routeName);
  }

  Future<void> openCategory() async {
    return open(CategoryScreen.routeName);
  }

  Future<void> openCategoryGroup() async {
    return open(CategoryGroupScreen.routeName);
  }

  Future<void> openReport([String? target]) async {
    return open(ReportScreen.routeName, arguments: {'target': target});
  }

  Future<void> openChatRoom(String uid) async {
    return open(ChatRoomScreen.routeName, arguments: {'uid': uid});
  }

  Future<void> openChatRooms() async {
    return open(ChatRoomsScreen.routeName);
  }

  Future<void> openReportForumMangement(String target, String id) async {
    return open(ReportPostManagementScreen.routeName, arguments: {
      'target': target,
      'id': id,
    });
  }

  Future<void> openUnitTest() async {
    return open(UnitTestScreen.routeName);
  }

  Future<void> openMenu() async {
    return open(MenuScreen.routeName);
  }

  Future openTest() async {
    return open(TestScreen.routeName);
  }

  Future openOtherUserProfile(String uid) {
    return open(OtherUserProfileScreen.routeName, arguments: {'uid': uid});
  }

  Future openChatRoomsBlocked() {
    return open(ChatRoomsBlockedScreen.routeName);
  }
}
