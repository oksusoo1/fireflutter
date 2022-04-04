import '../../fireflutter.dart';

/// PointApi
///
class PointApi {
  static PointApi? _instance;
  static PointApi get instance {
    _instance ??= PointApi();
    return _instance!;
  }

  Future getHistory({
    required int year,
    required int month,
  }) async {
    if (UserService.instance.notSignIn) throw ERROR_NOT_SIGN_IN;

    final res = await FunctionsApi.instance.request('pointHistory', {
      'year': year,
      'month': month,
    });

    if (res.data is String && (res.data as String).startsWith('ERROR_')) {
      throw res.data;
    }

    return (res.data as List).map((e) => PointHistoryModel.fromJson(e)).toList();
  }
}
