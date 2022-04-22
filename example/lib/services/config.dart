/// Configurations for app
///
/// All configuration must be set here.
class Config {
  // static const appName = String.fromEnvironment('APP_NAME', defaultValue: 'No app name');

  // For Google Map
  static const String googleApiAndroidKey = '...';
  static const String googleApiIosKey = '...';

  /// API key for data.go.kr
  /// It is used for `tour api`, `embassy list`.
  static const dataApiKey = "...";

  /// data.go.kr 의 Tour API 에서 사용하는 app name.
  static const tourAppName = '...';

  static Contacts contacts = Contacts();

  /// Open weather map api
  static String openWeatherMapApiKey = '...';

  /// How often (in minutes) does the app pull(refreshes) weather api information.
  ///
  static const int openWeatherMapUpdateInterval = 25;

  /// Seoul.go.kr API key
  static String seoulGoApiKey = '...';
  static String get seoulGoArtExhibitionUrl => "...";

  static String get seoulGoPublicServiceReservationUrl => '...';

  static String seoulCastlesPdfUrl = '...';

  static String embassyServiceUrl = '...';

  /// Currency settings
  ///
  ///
  static String currencyConverterApiUrl = '...';
  static String currencyConverterApiKey = 'bd6ed497a84496be7ee9';
  static int currencyConverterCacheExpiry = 60; // cache every 60 minutes

  /// [value] is the default value to be appear on the currency input box and
  /// can be cahnged by user.
  /// With this default value, the user will see the exchanged currency on the
  /// currency list. and the value of 10 would be a good to display the sample(default)
  /// exchange rates.
  static double currencyConverterDefaultAmount = 1.0;

  /// [code] is currently chosen currency code.
  /// It will be set to 'USD' by default(for the first time)
  /// And can be changed by user.
  static String defaultCurrencyCode = 'USD';

  /// [codes] has the default currency codes to display on the currency list
  /// for the first time.
  /// And user can change it later.
  static List<String> defaultConversionList = [
    "KRW",
    "USD",
    "CAD",
    "JPY",
    "CNY"
  ];

  /// Playstore & Appstore listing
  /// See details in README.md
  static String playstoreUrl =
      "https://play.google.com/store/apps/details?id=com.sonub.app";

  /// Warning: This url may not be opened on simulator. Test it with real device.
  static String appstoreUrl =
      "https://apps.apple.com/pk/app/WonderfulKorea/id1497100388";
}

class Contacts {
  String email = 'thruthesky@gmail.com';
  String phoneNumber = "+82-10-8693-4225";
  String name = 'JaeHo Song';
  String get inquiry => "sms://" + phoneNumber;
}
