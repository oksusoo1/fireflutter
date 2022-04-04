import 'package:dio/dio.dart';
import '../fireflutter.dart';

/// FunctionsApi
///
class FunctionsApi {
  static FunctionsApi? _instance;
  static FunctionsApi get instance {
    _instance ??= FunctionsApi();
    return _instance!;
  }

  String serverUrl = '';
  Function(String) onError = (s) => print;

  init({
    required String serverUrl,
    required Function(String) onError,
  }) {
    this.serverUrl = serverUrl;
    this.onError = onError;
  }

  String get password {
    final u = UserService.instance;
    return u.uid +
        "-" +
        u.user.registeredAt.toString() +
        "-" +
        u.user.updatedAt.toString() +
        "-" +
        u.user.point.toString();
  }

  Future request(String functionName, [Map<String, dynamic> data = const {}]) async {
    final dio = new Dio();
    data['uid'] = UserService.instance.uid;
    data['password'] = password;
    return await dio.post(
      FunctionsApi.instance.serverUrl + functionName,
      data: data,
    );
  }
}
