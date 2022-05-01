import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:fe/services/global.dart';

class OtherUserProfileLatestPosts extends StatelessWidget {
  const OtherUserProfileLatestPosts({required this.posts, Key? key}) : super(key: key);

  final List<PostModel> posts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sm),
          child: Text(
            'Lastest Posts',
            style: TextStyle(fontSize: 14, color: Colors.blueGrey),
          ),
        ),
        posts.isEmpty
            ? Padding(
                padding: EdgeInsets.all(sm),
                child: Text('User has not posted anything, yet.'),
              )
            : ListView.separated(
                itemCount: posts.length,
                shrinkWrap: true,
                padding: EdgeInsets.all(sm),
                physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (c, i) => spaceSm,
                itemBuilder: (c, i) {
                  final PostModel post = posts[i];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => service.router.openPostView(post: post),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${post.title}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: sm),
                        ),
                        Text(
                          '${post.category} - ${post.shortDateTime}',
                          style: TextStyle(fontSize: xsm, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }
}
