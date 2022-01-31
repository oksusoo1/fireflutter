import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

/// See readme.md
class DynamicLinksService {
  static DynamicLinksService? _instance;
  static DynamicLinksService get instance {
    _instance ??= DynamicLinksService();
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
