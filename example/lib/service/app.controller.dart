import 'package:fe/service/forum.model.dart';
import 'package:fe/service/route.names.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppController extends GetxController {
  static AppController of = Get.find<AppController>();

  UserModel user = UserModel();
  final ForumModel forum = ForumModel();

  @override
  onInit() {
    super.onInit();

    initAuthChanges();
  }

  /// User auth changes
  ///
  /// Warning! When user sign-out and sign-in quickly, it is expected
  /// - the user sign-out, first
  /// - and then, sign-in as anonymously,
  /// - and lastly, the user will sign-in as his auth.
  ///
  /// But it is asynchronus call. So, this may happens,
  /// - the user sign-out
  /// - then the user sign-in as his auth,
  /// - then lastly, the user sign-in as anonymous.
  ///
  /// So? Don't race on sign-out and sign-in.
  ///
  initAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((_user) async {
      if (_user == null) {
        print('User signed-out');
        user = UserModel();
      } else {
        if (_user.isAnonymous) {
          print('User sign-in as Anonymous;');
          user = UserModel();
        } else {
          user = await UserService.instance.get();
          print("User signed-in as; $user");
        }
      }
    });
  }

  Future<void> openProfile() async {
    if (user.signedOut) throw ERROR_SIGN_IN;
    return Get.toNamed(RouteNames.profile);
  }

  Future<void> openHome() async {
    return Get.toNamed(RouteNames.home);
  }

  Future<void> openForumList({String? category}) async {
    return Get.toNamed(RouteNames.postList, arguments: {'category': category});
  }
}
