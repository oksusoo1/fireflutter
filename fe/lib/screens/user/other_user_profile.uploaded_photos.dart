import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:fe/services/global.dart';

class OtherUserProfileUploadedPhotos extends StatelessWidget {
  const OtherUserProfileUploadedPhotos({
    required this.posts,
    Key? key,
  }) : super(key: key);

  final List<PostModel> posts;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sm),
          child: Text(
            'Lastest Photos',
            style: TextStyle(fontSize: 14, color: Colors.blueGrey),
          ),
        ),
        spaceXsm,
        posts.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: sm),
                child: Text('User has not uploaded any photos, yet.'),
              )
            : SizedBox(
                height: 100.0,
                child: ListView.separated(
                  itemCount: posts.length,
                  padding: EdgeInsets.symmetric(horizontal: sm),
                  physics: ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (c, i) => spaceXsm,
                  itemBuilder: (c, i) {
                    final dynamic post = posts[i];

                    return GestureDetector(
                      onTap: () => service.router.openPostView(post: post),
                      behavior: HitTestBehavior.opaque,
                      child: CachedImage(
                        posts[i].files[0],
                        width: 100,
                        borderRadius: xsm,
                      ),
                    );
                  },
                ),
              )
      ],
    );
  }
}
