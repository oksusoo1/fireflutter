import 'dart:developer';

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
    final httpsUri = Uri(queryParameters: data);

    log(FunctionsApi.instance.serverUrl + functionName + httpsUri.toString());

    try {
      final res = await dio.post(
        FunctionsApi.instance.serverUrl + functionName,
        data: data,
      );

      if (res.data is String && (res.data as String).startsWith('ERROR_')) {
        throw res.data;
      } else if (res.data is Map && res.data['code'] != null && res.data['code'] != '') {
        throw res.data['message'];
      } else if (res.data is String &&
          (res.data as String).contains('code') &&
          (res.data as String).contains('ERR_')) {
        throw res.data;
      } else {
        /// success
        return res.data;
      }
    } catch (e) {
      if (e is DioError) {
        throw e.message;
      } else {
        rethrow;
      }
    }
  }
}
