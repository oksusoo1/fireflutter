import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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

  /// Request and return the data.
  ///
  /// If there is any error, it throws the error.
  Future request(String functionName, [Map<String, dynamic> data = const {}]) async {
    final dio = new Dio();
    data['uid'] = UserService.instance.uid;
    data['password'] = password;

    final httpsUri = Uri(queryParameters: data);

    log(FunctionsApi.instance.serverUrl + functionName + httpsUri.toString());

    try {
      final res = await dio.post(
        FunctionsApi.instance.serverUrl + functionName,
        data: data,
      );
      if (res.data is String && (res.data as String).startsWith('ERROR_')) {
        throw res.data;
      } else if (res.data['code'] == 'error') {
        throw res.data['message'];
      } else {
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
