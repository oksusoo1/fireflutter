part of './fireflutter.dart';

class Base {
  /// Check if Firebase has initialized.
  bool isFirebaseInitialized = false;

  /// Fires after Firebase has initialized or if already initialized.
  /// The true event will be fired only once when Firebase initialized.
  BehaviorSubject<bool> firebaseInitialized = BehaviorSubject.seeded(false);

  /// Returns Firestore instance. Firebase database instance.
  FirebaseFirestore get db => FirebaseFirestore.instance;

  /// Default topic that all users(devices) will subscribe to
  final String allTopic = 'allTopicqwerty';

  /// Storage folder names
  ///
  /// * changed on 2020. 11. 23. This is not a breaking change.
  final String forumFolder = 'forum-photos'; // for photos and anything.
  final String profilePhotoFolder = 'user-profile-photos';

  /// To send push notification
  String firebaseServerToken;

  /// User document realtime update.
  StreamSubscription userDocSubscription;
  StreamSubscription userPublicDocSubscription;

  CollectionReference postsCol;
  CollectionReference usersCol;

  DocumentReference get publicDoc =>
      db.collection('meta').doc('user').collection('public').doc(user.uid);
  DocumentReference get tokenDoc =>
      db.collection('meta').doc('user').collection('token').doc(user.uid);

  DocumentReference getUserTokenDoc(String uid) =>
      db.collection('meta').doc('user').collection('token').doc(uid);
  CollectionReference get publicCol =>
      db.collection('meta').doc('user').collection('public');

  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  /// Device token for Firebase messaging.
  ///
  /// This will be available by default on Android. For iOS, this will be only\'
  /// available when user accepts the permission request.
  String firebaseMessagingToken;

  bool enableNotification;

  /// [authStateChange] is a link to `FirebaseAuth.instance.authStateChanges()`
  ///
  /// Use this to know if the user has logged in or not.
  ///
  /// You can do the following with [authStateChanges]
  /// ```
  /// StreamBuilder(
  ///   stream: ff.authStateChanges,
  ///   builder: (context, snapshot) { ... });
  /// ```
  Stream<User> authStateChanges;

  /// Firebase User instance
  ///
  /// Attention! [user] may not immediately be available after instantiating
  /// `FireFlutter` since [user] is only available after `authStateChanges`.
  /// And `authStateChanges` requires `StreamSubscription` which should be
  /// unsubscribed when it does not needed anymore.
  /// For this reason, it is not recommended to instantiate more than once
  /// instance of `FireFlutter`. You should create only one instance of
  /// `FireFlutter` and keep it as global variable and share it on all
  /// the runtime.
  ///
  /// This is firebase `User` object and it can be used as below.
  /// ```
  /// ff.user.updateProfile(displayName: nicknameController.text);
  /// ```
  User get user {
    if (isFirebaseInitialized) {
      return FirebaseAuth.instance.currentUser;
    } else
      return null;
  }

  /// User document data.
  Map<String, dynamic> userData = {};

  /// User public document data.
  Map<String, dynamic> publicData = {};

  bool get loggedIn => user != null;
  bool get notLoggedIn => !loggedIn;

  /// [userChange] event fires when
  /// - user document(without subcollection) like when user updates his profile
  /// - user log in,
  /// - user log out,
  /// - user verify his phone nubmer
  /// - user profile photo changes
  ///
  /// It is important to know that [authStateChanges] event happens only when
  /// user logs in or logs out.
  BehaviorSubject<UserChangeType> userChange = BehaviorSubject.seeded(null);

  /// [notification] will be fired whenever there is a push notification.
  /// the return data will the following and can be use when user receive notifications.
  ///
  /// ```
  /// {
  ///   "notification": {"body": body, "title": title},
  ///   "priority": "high",
  ///   "data": {
  ///     "click_action": "FLUTTER_NOTIFICATION_CLICK",
  ///     "id": id,
  ///     "status": "done",
  ///     "senderUid": user.uid,
  ///     'route': '/',
  ///     'screen': screen
  ///   }
  /// }
  /// ```
  // ignore: close_sinks
  PublishSubject notification = PublishSubject();

  // PublishSubject configDownload = PublishSubject();

  /// Set default properties to prevent null errors.
  Map<String, dynamic> _settings = {'forum': {}, 'app': {}};
  // ignore: close_sinks
  BehaviorSubject settingsChange = BehaviorSubject.seeded(null);

  // Map<String, dynamic> _translations;
  // ignore: close_sinks
  BehaviorSubject translationsChange = BehaviorSubject.seeded({});

  /// Aloglia search
  Algolia algolia;

  /// User profile information is private by default.
  ///
  /// If [openProfile] is set to true, then user profile information will be
  /// saved into `/meta/users/{uid}/{...}` which is open to public.
  ///
  /// For chat and other functionalities that do user search need this option.
  bool openProfile = false;

  initUser() {
    authStateChanges = FirebaseAuth.instance.authStateChanges();

    /// Note: listen handler will called twice if Firestore is working as offline mode.
    authStateChanges.listen((User user) {
      /// [userChange] event fires when user is logs in or logs out.
      userChange.add(UserChangeType.auth);

      /// Cancel listening user document.
      ///
      /// When user logs out, it needs to cancel the subscription, or
      /// `cloud_firestore/permission-denied` error will happen.
      if (userDocSubscription != null) {
        userDocSubscription.cancel();
      }
      if (userPublicDocSubscription != null) {
        userPublicDocSubscription.cancel();
      }

      /// user state changed(user logged in already)
      if (user != null) {
        /// Note: listen handler will called twice if Firestore is working as offlien mode.
        userDocSubscription = usersCol.doc(user.uid).snapshots().listen(
          (DocumentSnapshot snapshot) {
            if (snapshot.exists) {
              userData = snapshot.data();
              userChange.add(UserChangeType.document);
            }
          },
        );
        userPublicDocSubscription = publicDoc.snapshots().listen(
          (DocumentSnapshot snapshot) {
            if (snapshot.exists) {
              publicData = snapshot.data();
              userChange.add(UserChangeType.public);
            }
          },
        );

        updateUserSubscription(user);
      }
    });
  }

  /// Initialize Firebase
  ///
  /// Firebase is initialized asynchronously. It does not block the app by async/await.
  initFirebase() {
    // WidgetsFlutterBinding.ensureInitialized();
    return Firebase.initializeApp().then((firebaseApp) {
      isFirebaseInitialized = true;
      firebaseInitialized.add(isFirebaseInitialized);
      FirebaseFirestore.instance.settings =
          Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);

      usersCol = FirebaseFirestore.instance.collection('users');
      postsCol = FirebaseFirestore.instance.collection('posts');
      return firebaseApp;
    });
  }

  /// Update user meta data.
  ///
  /// It is merging with existing data.
  ///
  /// ```dart
  /// ff.updateUserMeta({
  ///   'public': { notifyPost: value },
  /// });
  /// ```
  // Future<void> updateUserMeta(Map<String, Map<String, dynamic>> meta) async {
  //   // Push default meta to user meta
  //   if (meta != null) {
  //     CollectionReference metaCol = usersCol.doc(user.uid).collection('meta');
  //     for (final key in meta.keys) {
  //       // Save data for each path.
  //       await metaCol.doc(key).set(meta[key], SetOptions(merge: true));
  //     }
  //   }
  // }

  /// Update user public data in `/users/{uid}/meta/public` document.
  ///
  /// [name] is the document data or property name
  /// if [value] is null, then [name] is considered as Map and it will merge
  /// into to public document.
  /// If [value] is not null, then [name] is a property of the public document
  /// and it will update only one property.
  ///
  /// [updatedAt] is always updatd.
  ///
  /// ```dart
  /// await updateUserPublic(public); // merge a map
  /// await updateUserPublic('a', 'apple'); // merge a key/value
  /// ```
  ///
  /// * change: `return publicDoc.set` causes a problem when user quickly register and then, register again. It has to `await`.
  Future<void> updateUserPublic(dynamic name, [dynamic value]) async {
    if (name == null) return;

    if (name is Map) {
      // name[updatedAt] = FieldValue.serverTimestamp();
      await publicDoc.set({
        ...name,
        ...{updatedAt: FieldValue.serverTimestamp()}
      }, SetOptions(merge: true));
    } else {
      await publicDoc.set({
        name: value,
        updatedAt: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  ///
  ///
  /// * changed at 2020. 11. 26. from `return tokenDoc` to `return await tokenDoc`.
  Future<dynamic> updateUserToken() async {
    if (notLoggedIn) return false;
    if (enableNotification == false) return false;
    if (firebaseMessagingToken == null) return false;
    return await tokenDoc
        .set({firebaseMessagingToken: true}, SetOptions(merge: true));
  }

  /// Update push notification tokens when userAuthStateChange.
  ///
  /// This re-subscribes all the topic when user restart the app. (The user does
  /// not need to re-login). This method works for Forums, Chats, or any other
  /// functionalities that has topic subscription.
  ///
  /// This method first looks for /meta/user/public/{uid} and get any fields
  /// that starts with `notify...` (which are considered as topics), then it
  /// will re-subscribe all the topic again.
  /// For instance, `notifyPost-qna`, `notifyComment-qna`, `notifyChat-room-id`,
  /// or anything that begins with `notify...` will be automatically subscribed.
  ///
  ///
  /// [user] is needed because when this method may be called immediately
  ///   after login but before `Firebase.AuthStateChange()` and when it happens,
  ///   the user appears not to be logged in even if the user already logged in.
  ///
  // Future<void> updateToken(User user) {
  //   if (enableNotification == false) return null;
  //   if (firebaseMessagingToken == null) return null;
  //   return FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user.uid)
  //       .collection('meta')
  //       .doc('tokens')
  //       .set({firebaseMessagingToken: true}, S'etOptions(merge: true));
  // }'
  //
  //
  // TODO: What if authStateChange happens too often. Usually when app
  // (re)starts, authStateChange happens twice. You may use debounce in such case.
  Future<void> updateUserSubscription(User user) async {
    if (enableNotification == false) return;
    if (firebaseMessagingToken == null) return;
    final docSnapshot = await publicDoc.get();

    /// If user public document does not exist, just return since the user
    /// didn't have subscription.
    if (!docSnapshot.exists) return;
    Map<String, dynamic> tokensDoc = docSnapshot.data();

    /// any uid starting with `notify` keyword will treat as a topic under the publicDoc
    tokensDoc.forEach((key, value) async {
      if (key.indexOf('notify') == 0) {
        if (value == true) {
          await subscribeTopic(key);
        } else {
          await unsubscribeTopic(key);
        }
      }
    });
  }

  Future subscribeTopic(String topicName) async {
    await FirebaseMessaging().subscribeToTopic(topicName);
  }

  Future unsubscribeTopic(String topicName) async {
    await FirebaseMessaging().unsubscribeFromTopic(topicName);
  }

  /// TODO: don't make it async/await since the app looks freezed on iOS.
  Future<void> initFirebaseMessaging() async {
    if (enableNotification == false) return;
    await _firebaseMessagingRequestPermission();

    firebaseMessagingToken = await firebaseMessaging.getToken();
    // print('token');
    // print(firebaseMessagingToken);
    if (user != null) {
      await updateUserToken();
    }

    /// subscribe to all topic
    await subscribeTopic(allTopic);

    _firebaseMessagingCallbackHandlers();
  }

  Future<void> _firebaseMessagingRequestPermission() async {
    /// Ask permission to iOS user for Push Notification.
    if (Platform.isIOS) {
      firebaseMessaging.onIosSettingsRegistered.listen((event) {
        // Do something after user accepts the request.
      });
      await firebaseMessaging
          .requestNotificationPermissions(IosNotificationSettings());
    } else {
      /// For Android, no permission request is required. just get Push token.
      await firebaseMessaging.requestNotificationPermissions();
    }
  }

  /// Do some sanitizing and call `notificationHandler` to deliver
  /// notification to app.
  _notifyApp(Map<String, dynamic> message, NotificationType type) {
    // print('notifyApp');
    // print(message);

    Map<dynamic, dynamic> notification =
        jsonDecode(jsonEncode(message['notification']));

    /// on `iOS`, `title`, `body` are insdie `message['aps']['alert']`.
    if (message['aps'] != null && message['aps']['alert'] != null) {
      notification = message['aps']['alert'];
    }

    /// on `iOS`, `message` has all the `data properties`.
    Map<dynamic, dynamic> data = message['data'] ?? message;

    /// Return if the senderUid is the owner.
    /// For testing you can pass data with test: true to by pass this condition
    if (data != null &&
        user != null &&
        data['senderUid'] == user.uid &&
        data['test'] == false) {
      return;
    }

    this.notification.add({
      'notification': notification,
      'data': data,
      'type': type,
    });
  }

  /// Firebase callback handlers for `onMessage`, `onLaunch` and `onResume`
  _firebaseMessagingCallbackHandlers() {
    /// Configure callback handlers for
    /// - foreground
    /// - background
    /// - exited
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage');
        _notifyApp(message, NotificationType.onMessage);
      },
      onLaunch: (Map<String, dynamic> message) async {
        // print('onLaunch');
        _notifyApp(message, NotificationType.onLaunch);
      },
      onResume: (Map<String, dynamic> message) async {
        // print('onResume');
        _notifyApp(message, NotificationType.onResume);
      },
    );
  }

  /// Send push notifications.
  ///
  /// [title] is the title of the Push Notification.
  /// [body] is the body of the Push Notification
  /// [token] is used to send Push Notification to a single token/device.
  /// [tokens] can be use to send push notification to multiple tokens/device.
  /// [topic] to send to specific topic.
  /// [test] default is false. If set to true it will show the message as well to the sender.
  /// [id] can be use as a params like postID, UserID, RoomID, or any ID you need to pass thru pushnotification.
  /// [screen] can be use as a route after the app is open you can use screen as a param to move to specific page.
  ///
  ///
  ///
  /// Prevent its return type is `FutureOr` by returns right boolean value.
  ///
  /// ! Warning - this method does not chunks the [tokens] list. Meaning, it can
  /// only have few tokens to send. And sending many tokens with this method is
  /// very bad. First, it has performance problem. For instance, there are 1,000
  /// users to send messages to. then the app needs to read 1,000 user docuemnts
  /// to read tokens, and 1,000 users may have 2,000 tokens in total. Second,
  /// It does not chunks, meaning it can only send messages less than 1,000.
  /// The other 1,000 tokens are simply ignored. This is a ciritical bug.
  /// Third, it's expendsive since it has to read document over again.
  /// So, do not use [tokens] when you are not sure. Use topic instead.
  ///
  Future<bool> sendNotification(
    String title,
    String body, {
    String id,
    String screen,
    String token,
    List<String> tokens,
    String topic,
    bool test,
  }) async {
    if (enableNotification == false) return false;
    if (firebaseServerToken == null) return false;

    if (token == null &&
        (tokens == null || tokens.length == 0) &&
        topic == null) return false;

    if (title == null || title == '') throw 'TITLE_IS_EMPTY';
    if (body == null || body == '') throw 'BODY_IS_EMPTY';

    final postUrl = 'https://fcm.googleapis.com/fcm/send';

    /// Check if it will send notification via single token, set of tokens and topic.
    final req = [];
    if (token != null) req.add({'key': 'to', 'value': token});
    if (topic != null) req.add({'key': 'to', 'value': "/topics/" + topic});
    if (tokens != null && tokens.isNotEmpty)
      req.add({'key': 'registration_ids', 'value': tokens});

    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "key=" + firebaseServerToken
    };

    bool success = true;

    req.forEach((el) async {
      final data = {
        "notification": {
          "body": body.length > 512 ? body.substring(0, 512) : body,
          "title": title.length > 128 ? title.substring(0, 128) : title,
        },
        "priority": "high",
        "data": {
          "id": id ?? '',
          "status": "done",
          "senderUid": loggedIn ? user.uid : '',
          "route": "/",
          "screen": screen ?? '',
          "test": test ?? false,
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
        },
      };

      data[el['key']] = el['value'];
      final String encodeData = jsonEncode(data);
      Dio dio = Dio();

      Response response = await dio.post(
        postUrl,
        data: encodeData,
        options: Options(
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        // on success do
        // print("notification success");
      } else {
        // on failure do
        // print("notification failure");
        success = false;
      }
    });
    return success;
  }

  Map<String, dynamic> getCommentParent(
      List<dynamic> comments, int parentIndex) {
    if (comments == null) return null;
    if (parentIndex == null) return null;

    return comments[parentIndex];
  }

  Future sendCommentNotification(
      Map<String, dynamic> post, Map<String, dynamic> data) async {
    List<String> uids = [];
    List<String> uidsForNotification = [];

    // Add post owner's uid
    uids.add(post['uid']);

    /// Get ancestors
    List<dynamic> ancestors = getAncestors(
      post['comments'],
      data['order'],
    );

    /// Get ancestors uid and eliminate duplicate
    for (dynamic c in ancestors) {
      if (uids.indexOf(c['uid']) == -1) uids.add(c['uid']);
    }

    String topicKey = NotificationOptions.comment(post['category']);

    // Only get uid that will recieve notification
    for (String uid in uids) {
      final docSnapshot = await db
          .collection('meta')
          .doc('user')
          .collection('public')
          .doc(uid)
          .get();
      // await usersCol.doc(uid).collection('meta').doc('public').get();

      if (!docSnapshot.exists) continue;

      Map<String, dynamic> publicData = docSnapshot.data();

      /// If the user has subscribed the forum, then it does not need to send notification again.
      if (publicData[topicKey] == true) {
        continue;
      }

      /// If the post owner has not subscribed to new comments under his post, then don't send notification.
      if (uid == post['uid'] && publicData[notifyPost] != true) {
        continue;
      }

      /// If the user didn't subscribe for comments under his comments, then don't send notification.
      if (publicData[notifyComment] != true) {
        continue;
      }
      uidsForNotification.add(uid);
    }

    /// Get tokens
    List<String> tokens = [];
    for (var uid in uidsForNotification) {
      final docSnapshot = await db
          .collection('meta')
          .doc('user')
          .collection('token')
          .doc(uid)
          .get();
      // await usersCol.doc(uid).collection('meta').doc('tokens').get();
      if (!docSnapshot.exists) continue;
      Map<String, dynamic> tokensDoc = docSnapshot.data();

      /// Merge tokens
      tokens = [...tokens, ...tokensDoc.keys];
    }

    /// TODO make the title and body of push notification optioanl.
    sendNotification(
      post['title'],
      data['content'],
      id: post['id'],
      screen: 'postView',
      topic: topicKey,
      tokens: tokens,
    );
  }

  /// Returns order of the new comment(to be created).
  ///
  /// [order] is;
  ///   - is the last comment's order when the created comment is the first depth comment of the post.
  ///   - the order of last comment of the sibiling.
  /// [depth] is the depth of newly created comment.
  getCommentOrder({
    String order,
    int depth: 0,
  }) {
    if (order == null) {
      return '999999.999.999.999.999.999.999.999.999.999.999.999';
    }
    List<String> parts = order.split('.');
    int n = int.parse(parts[depth]);
    parts[depth] = (n - 1).toString();
    for (int i = (depth + 1); i < parts.length; i++) {
      parts[i] = '999';
    }
    return parts.join('.');
  }

  /// Returns the ancestor comments of a comment.
  ///
  /// To get the ancestor comments based on the [order], it splits the parts of
  /// order and compare it to the comments in the middle of the comment thread.
  ///
  /// Use this method to get the parent comments of a comemnt.
  ///
  /// [order] is the comment to know its parent comemnts.
  ///
  /// If the comment is the first depth comment(comment right under post), then
  /// it will return empty array.
  ///
  /// The comment itself is not included in return array since it is itself. Not
  /// one of ancestor.
  ///
  List<dynamic> getAncestors(List<dynamic> comments, String order) {
    List<dynamic> ancestors = [];
    if (comments == null || comments.length == 0) return ancestors;
    List<String> parts = order.split('.');
    int len = parts.length;
    int depth = parts.indexWhere((element) => element == '999');
    if (depth == -1) depth = 11;

    List<String> orderOfAncestors = [];
    //// if [depth] is 0, then there is no ancestors.
    for (int i = 1; i < depth; i++) {
      List<String> newParts = List.from(parts);
      for (int j = i; j < len; j++) newParts[j] = '999';
      orderOfAncestors.add(newParts.join('.'));
    }

    for (String findOrder in orderOfAncestors) {
      for (var comment in comments) {
        if (comment['order'] == findOrder) {
          ancestors.add(comment);
        }
      }
    }
    return ancestors;

    // print('orderOfAncestors: $orderOfAncestors');

    // for (CommentModel comment in comments) {
    //   // List<String> commentParts = comment.order.split('.');
    //   for (int i = 0; i < parts.length; i++) {
    //     String compareOrder = parts[i];
    //   }
    // }
    // print(parts);
  }

  DocumentReference categoryDoc(String id) {
    return FirebaseFirestore.instance.collection('categories').doc(id);
  }

  CollectionReference postsCollection() {
    return FirebaseFirestore.instance.collection('posts');
  }

  DocumentReference postDocument(String id) {
    return postsCollection().doc(id);
  }

  DocumentReference postVoteDocument(String id) {
    return postsCollection().doc(id).collection('votes').doc(user.uid);
  }

  CollectionReference commentsCollection(String postId) {
    return postDocument(postId).collection('comments');
  }

  DocumentReference commentDocument(String postId, String commentId) {
    return commentsCollection(postId).doc(commentId);
  }

  DocumentReference commentVoteDocument(String postId, String commentId) {
    return commentsCollection(postId)
        .doc(commentId)
        .collection('votes')
        .doc(user.uid);
  }

  DocumentReference get myDoc => usersCol.doc(user.uid);

  CollectionReference get metaUserPublic =>
      db.collection('meta').doc('user').collection('public');

  // @deprecated
  // DocumentReference get myPublicDoc =>
  //     usersCol.doc(user.uid).collection('meta').doc('public');

  /// Returns the order string of the new comment
  ///
  /// @TODO: Move this method to `functions.dart`.
  ///
  getCommentOrderOf(Map<String, dynamic> post, int parentIndex) {
    if (parentIndex == null) {
      /// If the comment to be created is the first depth comment,
      /// - and if there are no comments under post, then return default order
      /// - or return the last order.
      return getCommentOrder(
          order: (post['comments'] != null && post['comments'].length > 0)
              ? post['comments'].last['order']
              : null);
    }

    /// If it is the first depth of child.
    // if (parent == null) {
    //   return getCommentOrder(
    //       order: (widget.post['comments'] != null &&
    //               widget.post['comments'].length > 0)
    //           ? widget.post['comments'].last['order']
    //           : null);
    // }

    Map<String, dynamic> parent =
        getCommentParent(post['comments'], parentIndex);
    // post['comments'][parentIndex];

    int depth = parent['depth'];
    String depthOrder = parent['order'].split('.')[depth];
    // print('depthOrder: $depthOrder');

    int i;
    for (i = parentIndex + 1; i < post['comments'].length; i++) {
      Map<String, dynamic> c = post['comments'][i];
      String findOrder = c['order'].split('.')[depth];
      if (depthOrder != findOrder) break;
    }

    final previousSiblingComment = post['comments'][i - 1];
    // print(
    //     'previousSiblingComment: ${previousSiblingComment['content']}, ${previousSiblingComment['order']}');
    return getCommentOrder(
      order: previousSiblingComment['order'],
      depth: parent['depth'] + 1,
    );
  }

  onSocialLogin(User user) async {
    final Map<String, dynamic> doc = await profile();
    if (doc == null) {
      /// first time registration
      await onRegister(user);
      await updateProfile({}, public: {
        notifyPost: true,
        notifyComment: true,
      });
    }

    await onLogin(user);
  }

  /// Login handler
  ///
  /// All the login including registration and social login will be handled here.
  Future<void> onLogin(User user) async {
    if (openProfile) {
      await updateUserPublic({
        'displayName': user.displayName,
        'photoURL': user.photoURL,
      });
    }
    await updateUserToken();
  }

  /// Profile update handler
  ///
  /// Whenever user updates his photo or nick name
  ///
  /// This method may fire userChange event.
  Future<void> onProfileUpdate() async {
    if (openProfile) {
      await updateUserPublic({
        'displayName': user.displayName,
        'photoURL': user.photoURL,
      });
      userChange.add(UserChangeType.profile);
    }
  }

  /// First time registration
  ///
  /// This method will be called on email/password registeration, all social
  /// logins for the first time, and kinds of registration.
  ///
  /// [createdAt] holds the time that the user as registered at.
  Future<void> onRegister(User user) async {
    await myDoc.set({
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    // await updateProfile({
    //   'createdAt': FieldValue.serverTimestamp(),
    //   'updatedAt': FieldValue.serverTimestamp(),
    // });
  }

  /// Pick an image from Camera or Gallery,
  /// then, compress
  /// then, fix rotation.
  ///
  /// 'permission-restricted' may be thrown if the app has no permission.
  Future<File> pickImage({
    ImageSource source,
    double maxWidth = 1024,
    int quality = 80,
  }) async {
    /// instantiate image picker.
    final picker = ImagePicker();

    permissionHander.Permission permission = source == ImageSource.camera
        ? permissionHander.Permission.camera
        : permissionHander.Permission.photos;

    /// request permission status.
    ///
    /// Android:
    ///   - Camera permission is automatically granted, meaning it will not ask for permission.
    ///     unless we specify the following on the AndroidManifest.xml:
    ///       - <uses-permission android:name="android.permission.CAMERA" />
    permissionHander.PermissionStatus permissionStatus =
        await permission.status;
    // print('permission status:');
    // print(permissionStatus);

    /// if permission is permanently denied,
    /// the only way to grant permission is changing in AppSettings.
    if (permissionStatus.isPermanentlyDenied) {
      await permissionHander.openAppSettings();
    }

    /// alert the user if the permission is restricted.
    if (permissionStatus.isRestricted) {
      throw 'permission-restricted';
    }

    /// check if the app have the permission to access camera or photos
    if (permissionStatus.isUndetermined || permissionStatus.isDenied) {
      /// request permission if not granted, or user haven't chosen permission yet.
      // print('requesting permisssion again');

      /// ? does not request permission again. (BUG: iOS) ??
      ///

      /// Ask permission.
      if (Platform.isAndroid) {
        await permission.request();
      }
    }

    PickedFile pickedFile = await picker.getImage(
      source: source,
      maxWidth: maxWidth,
      imageQuality: quality,
    );

    // return null if user picked nothing.
    if (pickedFile == null) return null;
    // print('pickedFile.path: ${pickedFile.path} ');

    String localFile =
        await getAbsoluteTemporaryFilePath(getRandomString() + '.jpeg');
    File file = await FlutterImageCompress.compressAndGetFile(
      pickedFile.path, // source file
      localFile, // target file. Overwrite the source with compressed.
      quality: quality,
    );

    return file;
  }

  /// Syncronize the Firebase `settings` collection to `this.settings`.
  ///
  /// Get settings in real time and merge(overwrite) it into the `_settings`.
  listenSettingsChange() {
    FirebaseFirestore.instance
        .collection('settings')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.size == 0) return;
      Map temp = {};
      snapshot.docs.forEach((DocumentSnapshot document) {
        temp[document.id] = document.data();
      });
      mergeSettings(temp);
      settingsChange.add(_settings);
    });
  }

  ///
  mergeSettings(Map<dynamic, dynamic> settingsFromFirestore) {
    settingsFromFirestore.forEach((key, document) {
      // _settings[key] = document;
      for (String name in document.keys) {
        if (_settings[key] == null) _settings[key] = {};
        _settings[key][name] = document[name];
      }
    });
  }

  /// set default translation then get translation to firestore 'translations'
  /// then add to current translation
  listenTranslationsChange(
      Map<String, Map<String, String>> defaultTranslations) {
    FirebaseFirestore.instance
        .collection('translations')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.size == 0) return;
      Map lns = {};
      snapshot.docs.forEach((DocumentSnapshot document) {
        lns[document.id] = document.data();
      });

      translationsChange.add(lns);
    });
  }

  /// Returns boolean based on the vote setting.
  ///
  /// [category] is the forum category and vote can be one of
  /// `VoteChoice.like` or `VoteChoice.dislike`.
  /// The default value is true if it is not set.
  bool voteSetting(String category, String vote) {
    if (_settings[category] == null || _settings[category][vote] == null) {
      return _settings['forum'][vote] ?? true;
    }
    return _settings[category][vote];
  }

  /// Get setting
  ///
  /// ```dart
  /// print(ff.getSetting());                   // returns the whole settings
  /// Map appSettings = ff.getSetting("app");   // returns the app document under /settings collection.
  /// if (appSettings != null)
  ///   print('GcpApiKey: ' + appSettings['GcpApiKey'] ?? '');
  /// ```
  ///
  getSetting([String name]) {
    if (name == null) return _settings;
    if (_settings == null) return null;
    return _settings[name] ?? null;
  }

  /// Get app settings under `/settings/app` document.
  ///
  /// This is a simple helper function to get `app` settings easily.
  /// If the key of the settings does not exist, it will return [defaultValue] which is null by default.
  ///
  /// ```dart
  /// appSettigns(); // returns all app settings.
  /// print('GcpApiKey: ' + ff.appSetting('GcpApiKey'));
  /// ```
  appSetting([String name, defaultValue]) {
    Map settings = getSetting("app");
    if (name == null) return settings;
    if (settings == null) return defaultValue;
    return settings[name] ?? defaultValue;
  }

  profile() async {
    DocumentSnapshot snapshot = await usersCol.doc(user.uid).get();
    if (snapshot.exists)
      return snapshot.data();
    else
      return null;
  }

  /// Updates a user's profile data.
  ///
  /// After update, `user` will have updated `displayName` and `photoURL`.
  ///
  /// Note. Whenever this method is called, it updates [updatedAt], which means
  /// it will always update user document and fires [userChange] event.
  ///
  /// It updates push notification token if the app needs.
  Future<void> updateProfile(Map<String, dynamic> data,
      {Map<String, dynamic> public}) async {
    if (data == null) return;
    if (data['displayName'] != null) {
      await user.updateProfile(displayName: data['displayName']);
    }
    if (data['photoURL'] != null) {
      await user.updateProfile(photoURL: data['photoURL']);
    }

    await user.reload();
    // final userDoc =
    //     FirebaseFirestore.instance.collection('users').doc(user.uid);

    data.remove('displayName');
    data.remove('photoURL');
    data['updatedAt'] = FieldValue.serverTimestamp();
    await myDoc.set(data, SetOptions(merge: true));

    await updateUserPublic(public);
    await updateUserToken();
    await onProfileUpdate();
  }

  int countLikes(obj) {
    if (obj == null || obj['likes'] == null) return 0;
    return (obj['likes'] as Map<String, dynamic>)
        .values
        .fold(0, (count, element) => element ? count + 1 : count);
  }

  int countDislikes(obj) {
    if (obj == null || obj['likes'] == null) return 0;
    return (obj['likes'] as Map<String, dynamic>)
        .values
        .fold(0, (count, element) => element == false ? count + 1 : count);
  }
}
