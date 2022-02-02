import 'package:fe/service/route.names.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  static AppController of = Get.find<AppController>();

  final ForumModel forum = ForumModel();

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

  Future<void> openPostCreate({String? category}) async {
    return Get.toNamed(RouteNames.postCreate, arguments: {'category': category});
  }

  Future<void> openAdmin() async {
    return Get.toNamed(RouteNames.admin);
  }
}
