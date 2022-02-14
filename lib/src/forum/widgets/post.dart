import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

class Post extends StatelessWidget {
  const Post({
    Key? key,
    this.contentBuilder,
    this.buttonBuilder,
    required this.post,
    required this.onReply,
    required this.onReport,
    required this.onEdit,
    required this.onDelete,
    required this.onLike,
    required this.onDislike,
    required this.onShare,
    required this.onImageTap,
    this.onHide,
  }) : super(key: key);

  final Function(String)? contentBuilder;
  final Function(Function)? buttonBuilder;
  final PostModel post;
  final Function(PostModel post) onReport;
  final Function(PostModel post) onReply;
  final Function(PostModel post) onEdit;
  final Function(PostModel post) onDelete;
  final Function(PostModel post) onLike;
  final Function(PostModel post) onDislike;
  final Function(PostModel post) onShare;
  final Function()? onHide;
  final Function(int index, List<String> fileList) onImageTap;

  bool get isMine => UserService.instance.currentUser?.uid == post.uid;

  @override
  Widget build(BuildContext context) {
    final content = contentBuilder != null
        ? contentBuilder!(post.displayContent)
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              post.displayContent,
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        content,
        ImageList(
          files: post.files,
          onImageTap: (i) => onImageTap(i, post.files),
        ),
        Text(post.id),
        Row(
          children: [
            _button('Comment', () => onReply(post)),
            _button('Report', () => onReport(post)),
            _button('Like', () => onLike(post)),
            _button('Dislike', () => onDislike(post)),
            _button('Share', () => onShare(post)),
            Spacer(),
            PopupMenuButton<String>(
              child: Padding(
                padding: EdgeInsets.only(right: 2),
                child: Icon(Icons.more_vert),
              ),
              initialValue: '',
              itemBuilder: (BuildContext context) => [
                if (isMine) ...[
                  PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                  PopupMenuDivider(),
                ],
                PopupMenuItem<String>(
                  value: 'report',
                  child: Text('Report', style: TextStyle(color: Colors.red)),
                ),
                PopupMenuItem<String>(value: 'hide_post', child: Text('Hide Post')),
                PopupMenuItem<String>(value: 'close_menu', child: Text('Close')),
              ],
              onSelected: (String value) async {
                /// TODO: find a way to programatically close ExpansionTile
                if (value == 'hide_post') {
                  if (onHide != null) onHide!();
                  return;
                }

                if (value == 'report') {
                  onReport(post);
                  return;
                }
                if (value == 'edit') {
                  onEdit(post);
                  return;
                }
                if (value == 'delete') {
                  onDelete(post);
                  return;
                }
              },
            )
          ],
        ),
      ],
    );
  }

  Widget _button(String label, Function() callback) {
    return buttonBuilder != null
        ? buttonBuilder!(callback)
        : TextButton(
            onPressed: callback,
            child: Text(
              label,
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
          );
  }
}
