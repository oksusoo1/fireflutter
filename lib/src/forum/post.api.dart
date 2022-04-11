import '../../fireflutter.dart';

/// PostApi
///
/// PostApi differs from PostService in the manner of communicating between backend.
/// See details on readme.md
class PostApi {
  static PostApi? _instance;
  static PostApi get instance {
    _instance ??= PostApi();
    return _instance!;
  }

  /// Create a post
  Future create({
    required String category,
    String? title,
    String? content,
    Map<String, dynamic> extra = const {},
  }) async {
    if (UserService.instance.notSignIn) throw ERROR_NOT_SIGN_IN;
    final data = {
      'title': title ?? '',
      'content': content ?? '',
      ...extra,
    };

    return FunctionsApi.instance.request('createPost', data: data, addAuth: true);
  }
}
