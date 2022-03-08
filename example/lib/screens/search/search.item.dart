import 'package:extended/extended.dart';
import 'package:fe/service/app.service.dart';
import 'package:flutter/material.dart';

class SearchItem extends StatelessWidget {
  const SearchItem({required this.item, Key? key}) : super(key: key);

  final Map<String, dynamic> item;

  bool get isComment => item.containsKey('postId');

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    children = [
      Text('Type: ${isComment ? 'Comment' : 'Post'}'),
      spaceXxs,
      Text('user ID : ${item['uid']}'),
      spaceXxs,
      if (!isComment) Text('Title: ${item['title']}'),
      Text('Content: ${item['content']}'),
      spaceXxs,
      Text('Id: ${item['id']}'),
      if (isComment) Text('postId: ${item['postId']}'),
    ];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => AppService.instance
          .openPostView(id: isComment ? item['postId'] : item['id']),
      child: Container(
        margin: EdgeInsets.only(bottom: xsm),
        padding: EdgeInsets.all(xs),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(xxs),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
