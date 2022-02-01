import 'package:fireflutter/fireflutter.dart';

/// See readme.md
class PostService {
  static PostService? _instance;
  static PostService get instance {
    _instance ??= PostService();
    return _instance!;
  }

  create(PostModel post) {
    print(post);
  }
}
