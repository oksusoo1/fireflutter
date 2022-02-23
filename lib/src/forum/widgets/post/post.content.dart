import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class PostContent extends StatelessWidget {
  const PostContent(this.post, {this.withImage = true, Key? key})
      : super(key: key);

  final PostModel post;
  final bool withImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: Colors.grey),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white),
          child: () {
            /// Youtube link 가 있다면, (HTML 이 있든 없든)
            // if (hasYoutubeLink(post.content)) {
            //   String content = convertYoutubeLinkToEmbedHTML(post.content);
            //   return HtmlContent(content);
            // } else if (post.html)
            if (post.isHtmlContent)
              return Html(data: post.displayContent);
            else
              return SelectableLinkify(
                text: post.displayContent,
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
