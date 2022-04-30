import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

/// Don't display error alert box for ErrorLevel.minor. It's just a notice or information.
///
enum ErrorLevel {
  minor,
  major,
  critical,
}

class ErrorInfo {
  String title;
  String content;
  ErrorLevel level;

  ErrorInfo(this.title, this.content, this.level);

  factory ErrorInfo.from(dynamic e, {String? title}) {
    String content = '';
    ErrorLevel lv = ErrorLevel.major;

    print('--> ErrorInfo.from(e); runtimeType: ${e.runtimeType}, Message: $e');

    /// Make [ArgumentError] as minor error. So, it won't be displayed user screen.
    if (e is ArgumentError) {
      lv = ErrorLevel.minor;
      title ??= 'Argument Error';
      content = e.toString();
    }

    // If the error is a string, then use the string.
    else if (e is String) {
      content = e;
    }
    // if the error is a PlatfromException, then display code and message.
    else if (e is PlatformException) {
      title = e.code;
      content = e.message ?? '';
    }
    // If the error is a TypeError, then handle is nicely.
    else if (e.runtimeType.toString() == '_TypeError') {
      final errstr = e.toString();
      if (errstr.contains('Future') && errstr.contains('is not a subtype of type')) {
        title = 'Await mistake';
        content = 'It is a mistake.\n\nHe should use await on Future operation.\n\n' + e.toString();
      } else {
        title = "Developer mistake!";
        content = 'Type error: ' + e.toString();
      }
    } else if (e.runtimeType.toString() == "NoSuchMethodError") {
      if (e.toString().contains("Closure call with mismatched arguments")) {
        title = 'Developer mistake!';
        content = 'Argument mismatch on closure call.\n\n$e';
      } else {
        title = 'Developer mistake.';
        content = "NoSuchMethodError; $e";
      }
    }

    /// FirebaseException handler
    else if (e is FirebaseException) {
      title = e.code.toUpperCase();
      content = '${e.message}';
      if (e is FirebaseAuthException) {
      } else if (e.toString().contains('firebase_storage')) {
        title = 'Storage';
      }
    }

    /// Dio error
    else if (e is DioError) {
      if (e.message.contains('host lookup')) {
        title = 'Connection error';
        content = 'Host lookup failed';
      } else if (e.message.contains('CERTIFICATE_VERIFY_FAILED')) {
        title = "Ceritificate verification failed";
        content =
            "Certificate error. Check if the app uses correct url scheme. CERTIFICATE_VERIFY_FAILED: application verification failure.";
      } else if (e.message.contains('Unexpected character')) {
        title = "Unexpected character in response";
        content = "PHP script in backend produced error. Check PHP script.";
      } else {
        title = 'HTTP connection error';
        content = e.message;
      }
    }

    /// Meilisearch handler
    else if (e.runtimeType.toString() == 'MeiliSearchApiException') {
      title = "Search settings misconfigured.";

      if (e.code.contains('invalid_filter')) {
        content = "Search filterables is not set properly. Please contact admin.";
      } else if (e.code.contains('invalid_sort')) {
        content = "Search sortables is not set properly. Please contact admin.";
      } else {
        content = "[${e.code}] - ${e.message}";
      }
    }

    // if it is a map error object and it has code and message.
    else if (e != null && e is Map && e['code'] != null && e['message'] != null) {
      /// if the object has code and message, then handle it.
      content = "${e['message']} (${e['code']})";
    }
    // if it is a map error object and it has only message.
    else if (e != null && e is Map && e['message'] != null) {
      if (e['message'] is String) {
        content = e['message'];
      }
    }
    // Display error message if anything else.
    else {
      content = e.toString();
    }

    return ErrorInfo(title ?? 'Error', content, lv);
  }
}

// ErrorInfo? errorInfo(e, [String? title]) {
//   String content = '';

//   // If the error is a string, then use the string.
//   if (e is String) {
//     content = e;
//   }
//   // if the error is a PlatfromException, then display code and message.
//   else if (e is PlatformException) {
//     title = e.code;
//     content = e.message ?? '';
//   }
//   // If the error is a TypeError, then handle is nicely.
//   else if (e.runtimeType.toString() == '_TypeError') {
//     final errstr = e.toString();
//     if (errstr.contains('Future') &&
//         errstr.contains('is not a subtype of type')) {
//       title = 'Await mistake';
//       content =
//           'It is a mistake.\n\nHe should use await on Future operation.\n\n' +
//               e.toString();
//     } else {
//       title = "Developer mistake!";
//       content = 'Type error: ' + e.toString();
//     }
//   } else if (e.runtimeType.toString() == "NoSuchMethodError") {
//     if (e.toString().contains("Closure call with mismatched arguments")) {
//       title = 'Developer mistake!';
//       content = 'Argument mismatch on closure call.\n\n$e';
//     } else {
//       title = 'Developer mistake.';
//       content = "NoSuchMethodError; $e";
//     }
//   }

//   /// FirebaseException handler
//   else if (e is FirebaseException) {
//     title = e.code.toUpperCase();
//     content = '${e.message}';
//     if (e is FirebaseAuthException) {
//     } else if (e.toString().contains('firebase_storage')) {
//       title = 'Storage';
//     }
//   }

//   /// Dio error
//   else if (e is DioError) {
//     if (e.message.contains('host lookup')) {
//       service.dioNoInternetError.add(0);
//       return null;
//     } else if (e.message.contains('CERTIFICATE_VERIFY_FAILED')) {
//       title = "Ceritificate verification failed";
//       content =
//           "Certificate error. Check if the app uses correct url scheme. CERTIFICATE_VERIFY_FAILED: application verification failure.";
//     } else if (e.message.contains('Unexpected character')) {
//       title = "Unexpected character in response";
//       content = "PHP script in backend produced error. Check PHP script.";
//     } else {
//       /// 네트워크 속도가 느려서 발생하는 에러의 경우, 한번에 여러개의 에러 메시지가 나타난다. 5초에 한개의 토스트 에러만 표시
//       service.dioConnectionError.add(0);
//       return null;
//     }
//   }

//   /// Meilisearch handler
//   else if (e.runtimeType.toString() == 'MeiliSearchApiException') {
//     title = "Search settings misconfigured.";

//     if (e.code.contains('invalid_filter')) {
//       content = "Search filterables is not set properly. Please contact admin.";
//     } else if (e.code.contains('invalid_sort')) {
//       content = "Search sortables is not set properly. Please contact admin.";
//     } else {
//       content = "[${e.code}] - ${e.message}";
//     }
//   }

//   // if it is a map error object and it has code and message.
//   else if (e != null && e is Map && e['code'] != null && e['message'] != null) {
//     /// if the object has code and message, then handle it.
//     content = "${e['message']} (${e['code']})";
//   }
//   // if it is a map error object and it has only message.
//   else if (e != null && e is Map && e['message'] != null) {
//     if (e['message'] is String) {
//       content = e['message'];
//     }
//   }
//   // Display error message if anything else.
//   else {
//     content = e.toString();
//   }

//   return ErrorInfo(title ?? 'Error', content);
// }
