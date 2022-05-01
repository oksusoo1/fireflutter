import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fe/services/global.dart';
import 'package:flutter/material.dart';
import 'package:extended/extended.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:fe/screens/user/other_user_profile.menu_button.dart';

import 'package:fe/widgets/common/fa_duotone_icon_menu.dart';
import 'package:fe/widgets/layout/layout.dart';
import 'package:fe/screens/user/other_user_profile.latest_posts.dart';
import 'package:fe/screens/user/other_user_profile.uploaded_photos.dart';
import 'package:fireflutter/fireflutter.dart';

class OtherUserProfileScreen extends StatefulWidget {
  const OtherUserProfileScreen({required this.arguments, Key? key}) : super(key: key);

  static final String routeName = '/otherUserProfile';
  final Map arguments;

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> with FirestoreMixin {
  bool loading = true;
  late UserModel user;
  List<PostModel> posts = [];
  List<PostModel> photos = [];
  int postCount = 0;
  int commentCount = 0;

  @override
  void initState() {
    super.initState();
    initUser();
  }

  initUser() async {
    user = widget.arguments['user'];

    setItem(() => loading = false);

    final Query q = postCol.where('uid', isEqualTo: user.uid);
    q.limit(10).orderBy('createdAt', descending: true).get().then((snapshot) {
      posts = snapshot.docs.map((val) => PostModel.fromJson(val.data() as Json, val.id)).toList();
      setState(() {});
    });

    q
        .where('hasPhoto', isEqualTo: true)
        .limit(10)
        .orderBy('createdAt', descending: true)
        .get()
        .then((snapshot) {
      photos = snapshot.docs.map((val) => PostModel.fromJson(val.data() as Json, val.id)).toList();
      setState(() {});
    });

    SearchService.instance.count(uid: user.uid).then((value) {
      if (mounted) setState(() => postCount = value);
    });

    SearchService.instance.count(uid: user.uid, index: 'comments').then((value) {
      if (mounted) setState(() => commentCount = value);
    });
  }

  setItem(Function callback) {
    if (mounted) setState(() => callback());
  }

  final countTextStyle = TextStyle(
    fontSize: md,
    color: Colors.blueGrey,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: Text(
        user.displayName,
        style: TextStyle(
          color: black,
        ),
      ),
      body: user.uid.isEmpty
          ? Center(
              child: loading
                  ? LinearProgressIndicator()
                  : Text(
                      'This user profile is unavailable.',
                    ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  spaceXl,
                  userReady(
                    builder: () => Column(children: [
                      Avatar(url: user.photoUrl, size: 100),
                      spaceSm,
                      Text(
                        user.displayName,
                        style: TextStyle(
                          fontSize: md,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Lv. ${user.level}',
                        style: TextStyle(
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        'Member since ${user.registeredDate}',
                        style: TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ]),
                  ),
                  spaceLg,
                  Container(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceAround,
                      children: [
                        OtherUserProfileMenuButton(
                          text: 'Posts',
                          icon: Text('$postCount', style: countTextStyle),
                          onTap: () => service.router.openSearchScreen(uid: user.uid),
                        ),
                        OtherUserProfileMenuButton(
                          text: 'Comments',
                          icon: Text('$commentCount', style: countTextStyle),
                          onTap: () =>
                              service.router.openSearchScreen(uid: user.uid, index: 'comments'),
                        ),
                        OtherUserProfileMenuButton(
                          text: 'Chat',
                          onTap: () => service.router.openChatRoom(user.uid),
                          icon: FaDuotoneIconMenu(
                            FontAwesomeIcons.duotoneCommentDots,
                            primaryColor: Colors.blue[400],
                            secondaryColor: Colors.yellow[400],
                            size: 26,
                          ),
                        ),
                        OtherUserProfileFriendMapButton(user: user),
                      ],
                    ),
                  ),
                  Divider(thickness: 1, height: xxl),
                  OtherUserProfileUploadedPhotos(posts: photos),
                  spaceMd,
                  OtherUserProfileLatestPosts(posts: posts),
                ],
              ),
            ),
    );
  }

  userReady({required Function builder}) {
    if (user.uid.isEmpty)
      return Spinner();
    else
      return builder();
  }
}

class OtherUserProfileFriendMapButton extends StatefulWidget {
  OtherUserProfileFriendMapButton({required this.user, Key? key}) : super(key: key);

  final UserModel user;

  @override
  State<OtherUserProfileFriendMapButton> createState() => _OtherUserProfileFriendMapButtonState();
}

class _OtherUserProfileFriendMapButtonState extends State<OtherUserProfileFriendMapButton> {
  bool sendingRequest = false;

  @override
  Widget build(BuildContext context) {
    return OtherUserProfileMenuButton(
      text: 'Friend Map',
      icon: sendingRequest
          ? SizedBox(
              height: 29,
              width: 29,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            )
          : FaDuotoneIconMenu(
              FontAwesomeIcons.duotoneMapMarkedAlt,
              primaryColor: red,
              secondaryColor: blue,
              size: 26,
            ),
      onTap: () async {
        if (UserService.instance.notSignedIn) {
          return service.error(ERROR_SIGN_IN);
        }
        setState(() => sendingRequest = true);

        /// TODO: 프랜드맵을 여기에 연결
        // await service.requestFriendMap(widget.user);
        setState(() => sendingRequest = false);
      },
    );
  }
}
