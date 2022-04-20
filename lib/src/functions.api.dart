import 'package:dio/dio.dart';
import '../fireflutter.dart';

/// FunctionsApi
///
/// See README.md for details.
class FunctionsApi {
  static FunctionsApi? _instance;
  static FunctionsApi get instance {
    _instance ??= FunctionsApi();
    return _instance!;
  }

  String serverUrl = '';
  // Function(String) onError = (s) => print;

  init({
    required String serverUrl,
    // required Function(String) onError,
  }) {
    this.serverUrl = serverUrl;
    // this.onError = onError;
  }

  String get password {
    final u = UserService.instance;
    return u.uid + "-" + u.user.registeredAt.toString() + "-" + u.user.updatedAt.toString();
  }

  /// Request and return the data.
  ///
  /// See details in README.md
  Future request(
    String functionName, {
    Map<String, dynamic> data = const {},
    bool addAuth = false,
  }) async {
    final dio = new Dio();

    if (addAuth) {
      data['uid'] = UserService.instance.uid;
      data['password'] = password;
    }

    /// Debug URL
    Map<String, dynamic> temp = Map<String, dynamic>.from(data);
    for (final k in temp.keys) {
      if (temp[k] != null && !(temp[k] is String) && !(temp[k] is List) && !(temp[k] is Map)) {
        temp[k] = data[k].toString();
      }
    }
    // final httpsUri = Uri(queryParameters: temp);
    // log(FunctionsApi.instance.serverUrl + functionName + httpsUri.toString());

    /// EO Debug URL

    try {
      final res = await dio.post(
        FunctionsApi.instance.serverUrl + functionName,
        data: data,
      );

      /// If the response is a string and begins with `ERROR_`, then it is an error.
      if (res.data is String && (res.data as String).startsWith('ERROR_')) {
        throw res.data;
      } else

      /// If the response is an Map(object) and has a non-empty value of `code` property, then it is considered as an error.
      if (res.data is Map && res.data['code'] != null && res.data['code'] != '') {
        throw res.data['code'];
      } else

      /// If the response is a JSON string and has `code` property and `ERR_` string, then it is firebase error.
      if (res.data is String &&
          (res.data as String).contains('code') &&
          (res.data as String).contains('ERR_')) {
        throw res.data;
      } else {
        /// success
        return res.data;
      }
    } catch (e) {
      /// Dio error
      if (e is DioError) {
        throw e.message;
      } else {
        /// Unknown error
        rethrow;
      }
    }
  }
}
