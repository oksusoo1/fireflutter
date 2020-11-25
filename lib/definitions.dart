part of './fireflutter.dart';

/// Constants
const String linkPhoneAuth = 'link';
const String signInPhoneAuth = 'signIn';
const String createdAt = 'createdAt';
const String updatedAt = 'updatedAt';

enum RenderType {
  postCreate,
  postUpdate,
  postDelete,
  commentCreate,
  commentUpdate,
  commentDelete,
  fileUpload,
  fileDelete,
  fetching,
  finishFetching
}

enum ForumStatus {
  noPosts,
  noMorePosts,
}

/// Error codes.
///
/// All error codes generated by fireflutter is upper cased.
const String LOGIN_FIRST = 'LOGIN_FIRST';
const String CATEGORY_EMPTY = 'CATEGORY_EMPTY';
const String CATEGORY_NOT_EXISTS = 'CATEGORY_NOT_EXISTS';
const String ALGOLIA_INDEX_NAME_IS_EMPTY = 'ALGOLIA_INDEX_NAME_IS_EMPTY';
const String UPLOAD_CANCELLED = 'UPLOAD_CANCELLED';

/// Algolia codes
const String ALGOLIA_APP_ID = 'ALGOLIA_APP_ID';
const String ALGOLIA_ADMIN_API_KEY = 'ALGOLIA_ADMIN_API_KEY';
const String ALGOLIA_INDEX_NAME = 'ALGOLIA_INDEX_NAME';

class NotificationOptions {
  static String notifyCommentsUnderMyPost = 'notifyPost';
  static String notifyCommentsUnderMyComment = 'notifyComment';

  /// "notifyPost_" + category
  static String post(String category) {
    return notifyCommentsUnderMyPost + '_' + category;
  }

  static String comment(String category) {
    return notifyCommentsUnderMyComment + '_' + category;
  }
}

/// For short
final String notifyPost = NotificationOptions.notifyCommentsUnderMyPost;
final String notifyComment = NotificationOptions.notifyCommentsUnderMyComment;

typedef Render = void Function(RenderType x);
const ERROR_SIGNIN_ABORTED = 'ERROR_SIGNIN_ABORTED';

enum UserChangeType { auth, document, register, profile, phoneNumber }
enum NotificationType { onMessage, onLaunch, onResume }

typedef NotificationHandler = void Function(Map<String, dynamic> messge,
    Map<String, dynamic> data, NotificationType type);

typedef SocialLoginErrorHandler = void Function(String error);
typedef SocialLoginSuccessHandler = void Function(User user);

class ForumData {
  /// [render] will be called when the view need to be re-rendered.
  ForumData({
    @required this.category,
    @required this.render,
    this.uid,
    this.noOfPostsPerFetch = 12,
  });

  /// This is for infinite scrolling in forum screen.
  RenderType _inLoading;
  bool get inLoading => _inLoading == RenderType.fetching;

  /// Tell the app to update(re-render) the screen.
  ///
  /// This method should be invoked whenever forum data changes like fetching
  /// more posts, comment updating, voting, etc.
  updateScreen(RenderType x) {
    _inLoading = x;
    render(x);
  }

  ForumStatus status;
  bool get shouldFetch => inLoading == false && status == null;
  bool get shouldNotFetch => !shouldFetch;

  String category;

  /// The app can show(search) posts of a user.
  ///
  /// [uid] could be the login user's uid or other user's uid.
  String uid;

  /// [fetched] becomes true if the app has fetched from Firestore.
  ///
  /// There might no no there even after it has fetched. So, [fetched] will be true
  /// while [posts] is still empty array.
  ///
  bool fetched = false;

  /// No of posts per each fetch. This can be overwritten by Firestore settings.
  int noOfPostsPerFetch;
  List<Map<String, dynamic>> posts = [];
  Render render;

  StreamSubscription postQuerySubscription;
  Map<String, StreamSubscription> commentsSubcriptions = {};

  /// This must be called on Forum screen widget `dispose` to cancel the subscriptions.
  leave() {
    postQuerySubscription.cancel();

    // TODO: unsubscribe all comments list stream subscriptions.
    if (commentsSubcriptions.isNotEmpty) {
      commentsSubcriptions.forEach((key, value) {
        value.cancel();
      });
    }
  }
}

// class VoteChoice {
//   static String like = 'like';
//   static String dislike = 'dislike';
// }

// /// Algolia search data to index
// class SearchData {
//   /// [path] is the path of document
//   final String path;
//   final String title;
//   final String content;

//   /// [stamp] is unix timestmap
//   final String stamp;
//   SearchData({@required this.path, this.title, this.content, this.stamp});
//   Map<String, dynamic> toMap() {
//     return {
//       'path': path,
//       if (title != null) 'title': title,
//       if (content != null) 'content': content,
//       if (stamp != null) 'stamp': stamp,
//     };
//   }
// }
