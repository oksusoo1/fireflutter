import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../fireflutter.dart';


class ForumList extends StatefulWidget {
  const ForumList({
    Key? key,
    required this.query,
    this.pageSize = 10,
    required this.builder,
    this.child,
  }) : super(key: key);

  /// The query that will be paginated.
  ///
  /// When the query changes, the pagination will restart from first page.
  final Query query;

  /// The number of items that will be fetched at a time.
  ///
  /// When it changes, the current progress will be preserved.
  final int pageSize;

  /// A widget that will be passed to [builder] for optimizations purpose.
  ///
  /// Since this widget is not created within [builder], it won't rebuild
  /// when the query emits an update.
  final Widget? child;

  final Function(List<PostModel>) builder;

  @override
  State<ForumList> createState() => _ForumListState();
}

class _ForumListState extends State<ForumList> {
  List<PostModel> posts = [];
  bool hasMore = true;
  bool isFetching = false;
  int pageNo = 0;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
