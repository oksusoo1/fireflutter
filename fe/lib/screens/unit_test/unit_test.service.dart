import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';

class UnitTestService with UnitTestMixin {
  static UnitTestService? _instance;
  static UnitTestService get instance => _instance ?? (_instance ??= UnitTestService());

  Future comeBack() async {
    AppService.instance.router.back();
    return wait(200, 'Opening unit test screen.');
  }
}
