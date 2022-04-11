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
  Future<PostModel> create({
    required String category,
    String? subcategory,
    String? documentId,
    String? title,
    String? content,
    String? summary,
    List<String> files = const [],
    Map<String, dynamic> extra = const {},
  }) async {
    if (UserService.instance.notSignIn) throw ERROR_NOT_SIGN_IN;
    final data = {
      'category': category,
      if (subcategory != null && subcategory != '') 'subcategory': subcategory,
      if (documentId != null && documentId != '') 'documentId': documentId,
      'title': title ?? '',
      'content': content ?? '',
      if (summary != null && summary != '') 'summary': summary,
      'files': files,
      ...extra,
    };

    final res = await FunctionsApi.instance.request(
      FunctionName.postCreate,
      data: data,
      addAuth: true,
    );
    return PostModel.fromJson(res);
  }
}
