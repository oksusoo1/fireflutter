import 'package:fe/service/route.names.dart';
import 'package:fireflutter/fireflutter.dart';

class AppService {
  static AppService? _instance;
  static AppService get instance {
    if (_instance == null) {
      _instance = AppService();
    }
    return _instance!;
  }

  Future<void> openProfile() async {
    if (UserService.instance.user.signedOut) throw ERROR_SIGN_IN;
    return Get.toNamed(RouteNames.profile);
  }

  Future<void> openHome() async {
    return Get.toNamed(RouteNames.home);
  }

  Future<void> openForumList({String? category}) async {
    return Get.toNamed(RouteNames.postList, arguments: {'category': category});
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

  Future<void> openReportForumMangement(String target, String id) async {
    return Get.toNamed(RouteNames.reportForumManagement, arguments: {
      'target': target,
      'id': id,
    });
  }
}
