import 'package:extended/extended.dart' as ex;
import 'package:fe/service/app.router.dart';
import 'package:fireflutter/fireflutter.dart';

class AppService {
  static AppService? _instance;
  static AppService get instance {
    if (_instance == null) {
      _instance = AppService();
    }
    return _instance!;
  }

  final router = AppRouter.instance;

  error(e) {
    ex.error(TranslationService.instance.tr(e.toString()));
    // if (UnitTestService.instance.onError != null) {
    //   UnitTestService.instance.onError!(e);
    // }
  }
}
