import 'package:extended/extended.dart';
import 'package:fe/service/app.service.dart';
import 'package:fe/service/global.keys.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

mixin ForumMixin {
  /// [post] is the post
  /// [comment] is null for immediate child comment or the parent comment
  onReply(BuildContext context, PostModel post, [CommentModel? comment]) async {
    return showDialog(
      context: context,
      builder: (_) {
        return CommentEditDialog(
          onCancel: AppService.instance.back,
          onError: error,
          onSubmit: (Json form, progress) async {
            try {
              progress(true);
              await CommentApi.instance.create(
                postId: post.id,
                parentId: comment?.id ?? post.id,
                content: form['content'],
                files: form['files'],
              );
              AppService.instance.back();
            } catch (e) {
              error(e);
              progress(false);
            }
          },
        );
      },
    );
  }

  /// Comment edit
  onEdit(BuildContext context, CommentModel comment) async {
    return showDialog(
      context: context,
      builder: (_) {
        return CommentEditDialog(
          comment: comment,
          onCancel: AppService.instance.back,
          onError: error,
          onSubmit: (Json form, progress) async {
            try {
              progress(true);
              await CommentApi.instance.update(
                id: comment.id,
                content: form['content'],
                files: form['files'],
              );

              // await comment.update(
              //   content: form['content'],
              //   files: form['files'],
              // );
              AppService.instance.back();
            } catch (e) {
              error(e);
              progress(false);
            }
          },
        );
      },
    );
  }

  /// Deleting comment or post
  @Deprecated('Use PostApi or CommentApi to delete')
  onDelete(dynamic postOrComment) async {
    try {
      if (postOrComment is PostModel) {
        await postOrComment.delete();
        alert('Post deleted', 'You have deleted this post.');
      } else if (postOrComment is CommentModel) {
        await postOrComment.delete();
        alert('Comment deleted', 'You have deleted this comment.');
      }
    } catch (e) {
      error(e);
    }
  }

  onLike(dynamic postOrComment) async {
    try {
      await postOrComment.feedLike();
    } catch (e) {
      error(e);
    }
  }

  onDislike(dynamic postOrComment) async {
    try {
      await postOrComment.feedDislike();
    } catch (e) {
      error(e);
    }
  }

  onReport(dynamic postOrComment) async {
    final input = TextEditingController(text: '');
    String? re = await showDialog(
      context: globalNavigatorKey.currentContext!,
      builder: (c) => AlertDialog(
        title: Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reason'),
            TextField(
              controller: input,
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              AppService.instance.back();
            },
            child: Text('close'),
          ),
          TextButton(
            onPressed: () async {
              AppService.instance.back(input.text);
            },
            child: Text('submit'),
          ),
        ],
      ),
    );

    if (re == null) return;
    try {
      await postOrComment.report(input.text);
      alert('Report success', 'You have reported this post.');
    } catch (e) {
      error(e);
    }
  }

  onImageTapped(BuildContext ctx, int initialIndex, List<String> files) {
    // return alert('Display original image', 'TODO: display original images with a scaffold.');
    return showDialog(
      context: ctx,
      builder: (context) =>
          Dialog(child: ImageViewer(files, initialIndex: initialIndex)),
    );
  }
}
