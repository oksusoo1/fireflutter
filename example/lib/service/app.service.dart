import 'package:fe/screens/admin/admin.screen.dart';
import 'package:fe/screens/admin/category.screen.dart';
import 'package:fe/screens/admin/report.post.management.screen.dart';
import 'package:fe/screens/admin/report.screen.dart';
import 'package:fe/screens/forum/post.form.screen.dart';
import 'package:fe/screens/forum/post.list.screen.dart';
import 'package:fe/screens/home/home.screen.dart';
import 'package:fe/screens/profile/profile.screen.dart';
import 'package:fe/service/global.keys.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AppService {
  static AppService? _instance;
  static AppService get instance {
    if (_instance == null) {
      _instance = AppService();
    }
    return _instance!;
  }

  void back([dynamic data]) {
    Navigator.pop(globalNavigatorKey.currentContext!, data);
  }

  Future<void> open(String routeName, {Map<String, dynamic>? arguments}) {
    return Navigator.pushNamed(
      globalNavigatorKey.currentContext!,
      routeName,
      arguments: arguments,
    );
  }

  Future<void> openProfile() async {
    if (UserService.instance.user.signedOut) throw ERROR_SIGN_IN;
    return open(ProfileScreen.routeName);
  }

  /// TODO: remove all the routes from route stack
  Future<void> openHome() async {
    return open(HomeScreen.routeName);
  }

  Future<void> openForumList({String? category}) async {
    return open(PostListScreen.routeName, arguments: {'category': category});
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

  Future<void> openReport([String? target]) async {
    return open(ReportScreen.routeName, arguments: {'target': target});
  }

  Future<void> openReportForumMangement(String target, String id) async {
    return open(ReportPostManagementScreen.routeName, arguments: {
      'target': target,
      'id': id,
    });
  }
}
