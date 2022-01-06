class AppService {
  static AppService? _instance;
  static AppService get instance {
    _instance ??= AppService();
    return _instance!;
  }
}
