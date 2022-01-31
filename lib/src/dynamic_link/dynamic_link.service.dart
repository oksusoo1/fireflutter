import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

/// See readme.md
class DynamicLinkService {
  static DynamicLinkService? _instance;
  static DynamicLinkService get instance {
    _instance ??= DynamicLinkService();
    return _instance!;
  }

  // Get any initial links
  Future<PendingDynamicLinkData?> get initialLink => FirebaseDynamicLinks.instance.getInitialLink();

  listen(Function(Uri?) callback) {
    /// Initialize dynamic link listeners
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri? deepLink = dynamicLinkData.link;

      if (deepLink != null) {
        callback(deepLink);
      }
    }, onError: (e) {
      print(e.toString());
    });
  }
}
