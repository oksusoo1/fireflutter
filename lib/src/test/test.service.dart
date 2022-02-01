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
  int _countSuccess = 0;

  reset() {
    _countError = 0;
  }

  testError(dynamic e, String message) {
    _countError++;
    debugPrint('🛑 ---------> ERROR[$_countError] $e - $message');
  }

  testSuccess(String message) {
    _countSuccess++;
    debugPrint('👍 ---------> SUCCESS[$_countSuccess]; $message');
  }

  ///
  expectSuccess(Future future, [String message = '']) async {
    try {
      await future;
      testSuccess(message);
    } catch (e) {
      testError(e, message);
    }
  }

  ///
  expectFailure(Future future, [String message = '']) async {
    try {
      await future;
      testError('Error expected', message);
    } catch (e) {
      testSuccess(message);
    }
  }
}
