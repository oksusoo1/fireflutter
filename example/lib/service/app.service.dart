import 'package:fe/screens/admin/admin.screen.dart';
import 'package:fe/screens/admin/category.screen.dart';
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
import 'package:dio/dio.dart';

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

  Future getAddresses(String keyword) async {
    final url =
        "https://www.juso.go.kr/addrlink/addrEngApi.do?currentPage=1&countPerPage=10&keyword=$keyword&confmKey=U01TX0FVVEgyMDIyMDQwNzIyMDI0MDExMjQzNzE=&resultType=json";
    final dio = Dio();

    final res = await dio.get(url);

    print(res.data);
  }

  Future inputAddress(context) async {
    return showDialog(
      context: context,
      builder: (context) {
        final input = TextEditingController();
        return StatefulBuilder(
            builder: ((context, setState) => AlertDialog(
                  title: Text('Yo'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: input,
                              decoration: InputDecoration(label: Text("input address")),
                              onSubmitted: (s) {
                                getAddresses(s);
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () => getAddresses(input.text),
                            icon: Icon(Icons.send),
                          )
                        ],
                      ),
                      Text(
                        'i.e) 536-9, Sinsa-dong',
                        style: TextStyle(
                          fontSize: 11,
                        ),
                      )
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Select'),
                    ),
                  ],
                )));
      },
    );
  }
}
