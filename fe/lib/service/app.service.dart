import 'package:fe/screens/admin/admin.screen.dart';
import 'package:fe/screens/admin/category.screen.dart';
import 'package:fe/screens/admin/category_group.screen.dart';
import 'package:fe/screens/admin/report.post.management.screen.dart';
import 'package:fe/screens/admin/report.screen.dart';
import 'package:fe/screens/admin/translatoins.screen.dart';
import 'package:fe/screens/chat/chat.room.screen.dart';
import 'package:fe/screens/forum/post.form.screen.dart';
import 'package:fe/screens/forum/post.list.screen.dart';
import 'package:fe/screens/forum/post.view.screen.dart';
import 'package:fe/screens/search/search.screen.dart';
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

  Future<void> open(String routeName, {Map? arguments}) {
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

  Future<void> openHome() async {
    return open(HomeScreen.routeName);
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

  Future<void> openReportForumMangement(String target, String id) async {
    return open(ReportPostManagementScreen.routeName, arguments: {
      'target': target,
      'id': id,
    });
  }
}
