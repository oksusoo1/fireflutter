import 'package:firebase_core/firebase_core.dart';
import '../../fireflutter.dart';
import 'package:flutter/material.dart';

class ReportPostManagement extends StatefulWidget {
  const ReportPostManagement({
    required this.id,
    required this.onError,
    required this.builder,
    Key? key,
  }) : super(key: key);

  final String id;
  final Function(dynamic) onError;
  final Widget Function(PostModel) builder;

  @override
  _ReportPostManagementState createState() => _ReportPostManagementState();
}

class _ReportPostManagementState extends State<ReportPostManagement>
    with FirestoreMixin {
  PostModel? post;
  @override
  void initState() {
    super.initState();

    () async {
      try {
        final event = await postCol.doc(widget.id).get();

        if (event.exists) {
          post = PostModel.fromJson(
              event.data() as Map<String, dynamic>, event.id);
        } else {
          post = PostModel();
        }
        setState(() {});
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          // If user document does not exists, it comes here with the follow error;
          // [firebase_database/permission-denied] Client doesn't have permission to access the desired data.
          // debugPrint(e.toString());
          setState(() => post = PostModel());
        } else {
          rethrow;
        }
      } catch (e) {
        rethrow;
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    if (post == null)
      return Center(child: CircularProgressIndicator.adaptive());
    return widget.builder(post!);
  }
}
