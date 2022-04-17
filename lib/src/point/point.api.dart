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

    final res = await FunctionsApi.instance.request('pointHistory',
        data: {
          'year': year.toString(),
          'month': month.toString(),
        },
        addAuth: true);

    return (res as List).map((e) => PointHistoryModel.fromJson(e)).toList();
  }
}
