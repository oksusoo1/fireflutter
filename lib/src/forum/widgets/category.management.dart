import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

class CategoryManagement extends StatefulWidget {
  CategoryManagement({
    Key? key,
    this.padding = const EdgeInsets.all(0),
    required this.onError,
    required this.onCreate,
  }) : super(key: key);

  final EdgeInsets padding;
  final Function(dynamic) onError;
  final Function(Map<String, dynamic>) onCreate;

  @override
  State<CategoryManagement> createState() => _CategoryManagementState();
}

class _CategoryManagementState extends State<CategoryManagement> with FirestoreBase {
  final category = TextEditingController();
  final title = TextEditingController();
  final description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Category menagement'),
        const Text('Create a category'),
        const Divider(),
        const Text('Category. Ex) qna, discussion, job'),
        TextField(controller: category),
        const Divider(),
        const Text('Title'),
        TextField(controller: title),
        const Divider(),
        const Text('Description'),
        TextField(controller: description),
        ElevatedButton(
          onPressed: () async {
            try {
              final data = {
                'title': title.text,
                'description': description.text,
              };
              final doc = await categoryCol.doc(category.text).get();
              if (doc.exists) throw ERROR_CATEGORY_EXISTS;
              await categoryCol.doc(category.text).set(data, SetOptions(merge: true));
              title.text = '';
              description.text = '';
              category.text = '';
              setState(() {});
              widget.onCreate(data);
            } catch (e) {
              widget.onError(e);
            }
          },
          child: const Text('CREATE CATEGORY'),
        ),
        Expanded(
          child: FirestoreListView<Map<String, dynamic>>(
            query: categoryCol.orderBy('title') as Query<Map<String, dynamic>>,
            itemBuilder: (context, snapshot) {
              Map<String, dynamic> cat = snapshot.data();

              return ListTile(
                title: Text(cat['title']),
              );
            },
          ),
        ),
      ]),
    );
  }
}
