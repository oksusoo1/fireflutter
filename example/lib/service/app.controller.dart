import 'package:fe/service/route.names.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  static AppController of = Get.find<AppController>();

  @override
  onInit() {
    super.onInit();
  }

  Future<void> openProfile() async {
    if (UserService.instance.user.signedOut) throw ERROR_SIGN_IN;
    return Get.toNamed(RouteNames.profile);
  }

  Future<void> openHome() async {
    return Get.toNamed(RouteNames.home);
  }

  Future<void> openForumList({String? category}) async {
    return Get.toNamed(RouteNames.forumList, arguments: {'category': category});
  }

  /// Returns post id of newly created post.
  Future<dynamic> openPostForm({String? category, PostModel? post}) async {
    return Get.toNamed(RouteNames.postForm, arguments: {
      'category': category,
      'post': post,
    });
  }

  Future<void> openAdmin() async {
    return Get.toNamed(RouteNames.admin);
  }

  Future<void> openCategory() async {
    return Get.toNamed(RouteNames.category);
  }

  Future<void> openReport([String? target]) async {
    return Get.toNamed(RouteNames.report, arguments: {'target': target});
  }
}
