import '../../fireflutter.dart';

/// CommentApi
///
/// CommentApi differs from PostService in the manner of communicating between backend.
/// See details on readme.md
class CommentApi {
  static CommentApi? _instance;
  static CommentApi get instance {
    _instance ??= CommentApi();
    return _instance!;
  }

  /// Create a post
  Future<CommentModel> create({
    required String postId,
    required String parentId,
    String content = '',
    List<String> files = const [],
  }) async {
    if (UserService.instance.notSignIn) throw ERROR_NOT_SIGN_IN;
    if (UserService.instance.user.ready == false)
      throw UserService.instance.user.profileError;
    final data = {
      'postId': postId,
      'parentId': parentId,
      'content': content,
      'files': files,
    };

    final res = await FunctionsApi.instance.request(
      FunctionName.commentCreate,
      data: data,
      addAuth: true,
    );

    return CommentModel.fromJson(res);
  }

  /// Comment update
  Future<CommentModel> update({
    required String id,
    String content = '',
    List<String> files = const [],
  }) async {
    final data = {
      'id': id,
      'content': content,
      'files': files,
    };

    final res = await FunctionsApi.instance.request(
      FunctionName.commentUpdate,
      data: data,
      addAuth: true,
    );

    return CommentModel.fromJson(res);
  }

  Future<String> delete(String id) async {
    final res = await FunctionsApi.instance.request(
      FunctionName.commentDelete,
      data: {'id': id},
      addAuth: true,
    );

    return res['id'];
  }
}
