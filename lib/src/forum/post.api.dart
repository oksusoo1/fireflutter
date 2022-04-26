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
    if (UserService.instance.user.ready == false) throw UserService.instance.user.profileError;

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

  /// Post update
  Future<PostModel> update({
    required String id,
    required String title,
    required String content,
    List<String> files = const [],
    String? summary,
    Json extra = const {},
  }) async {
    final data = {
      ...{
        'id': id,
        'title': title,
        'content': content,
        'files': files,
        if (summary != null) 'summary': summary,
      },
      ...extra
    };

    final res = await FunctionsApi.instance.request(
      FunctionName.postUpdate,
      data: data,
      addAuth: true,
    );

    return PostModel.fromJson(res);
  }

  Future<String> delete(String id) async {
    final res = await FunctionsApi.instance.request(
      FunctionName.postDelete,
      data: {'id': id},
      addAuth: true,
    );

    return res['id'];
  }
}
