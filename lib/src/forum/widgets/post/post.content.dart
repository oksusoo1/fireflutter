import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:wonderfulkorea/widgets/common/html_content.dart';
import 'package:wonderfulkorea/packages/local/wordpress/lib/wordpress.dart';
import 'package:url_launcher/url_launcher.dart';

class ForumListPostContent extends StatelessWidget {
  const ForumListPostContent(this.post, {this.withImage = true, Key? key}) : super(key: key);

  final WPPost post;
  final bool withImage;

  @override
  Widget build(BuildContext context) {
    // printLongString(post.content);
    return Column(
      children: [
        Divider(color: Colors.grey),
        Container(
          padding: EdgeInsets.symmetric(horizontal: sm, vertical: xs),
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white),
          child: () {
            /// Youtube link 가 있다면, (HTML 이 있든 없든)
            if (hasYoutubeLink(post.content)) {
              String content = convertYoutubeLinkToEmbedHTML(post.content);
              return HtmlContent(content);
            } else if (post.html)

              /// Youtube link 는 없지만, HTML 이면,
              return HtmlContent(post.content);
            else
              return SelectableLinkify(
                text: post.content,
                onOpen: (link) async {
                  if (await canLaunch(link.url)) {
                    await launch(link.url);
                  } else {
                    throw 'Could not launch $link';
                  }
                },
              );
          }(),
        ),
        Divider(color: Colors.grey),
      ],
    );
  }
}
