import '../../fireflutter.dart';

/// ReportApi
///
/// ReportApi differs from PostService in the manner of communicating between backend.
/// See details on readme.md
class ReportApi {
  static ReportApi? _instance;
  static ReportApi get instance {
    _instance ??= ReportApi();
    return _instance!;
  }

  /// [target] can be one of 'post', 'commnet', 'user', or any object type.
  /// [targetId] is the id of the object type.
  /// [reason] is the reason why the sign-in user is reporting.
  Future<ReportModel> report({
    required String target,
    required String targetId,
    String? reason,
  }) async {
    final json = await FunctionsApi.instance.request(
      FunctionName.report,
      data: {
        'target': target,
        'targetId': targetId,
        'reason': reason ?? '',
      },
      addAuth: true,
    );
    return ReportModel.fromJson(json);
  }
}
