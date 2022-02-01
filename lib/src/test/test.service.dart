import 'package:flutter/material.dart';

/// See readme.md
class TestService {
  static TestService? _instance;
  static TestService get instance {
    _instance ??= TestService();
    return _instance!;
  }

  /// Report test
  ///
  int _countError = 0;

  reset() {
    _countError = 0;
  }

  _testError(dynamic e, String message) {
    _countError++;
    debugPrint('🛑 ---------> ERROR[$_countError] $e - $message');
  }

  _testSuccess(String message) {
    debugPrint('---------> SUCCESS; $message');
  }

  ///
  expectSuccess(Future future, [String message = '']) async {
    try {
      await future;
      _testSuccess(message);
    } catch (e) {
      _testError(e, message);
    }
  }

  ///
  expectFailure(dynamic func, [String message = '']) async {
    try {
      await func();
      _testError('Error expected', message);
    } catch (e) {
      _testSuccess(message);
    }
  }
}
