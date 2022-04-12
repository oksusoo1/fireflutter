import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../fireflutter.dart';
import 'package:flutter/material.dart';

class CategoryGroupManagement extends StatelessWidget with FirestoreMixin {
  CategoryGroupManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Category menus'),
        FutureBuilder<DocumentSnapshot>(
            future: forumSettingDoc.get(),
            builder: (c, snapshot) {
              if (snapshot.hasData) {
                Map data = snapshot.data?.data() as Map<String, dynamic>;
                String categoryMenu = data['categoryMenu'];
                return TextField(
                  controller: TextEditingController()..text = categoryMenu,
                  onChanged: (value) =>
                      forumSettingDoc.set({'categoryMenu': value}, SetOptions(merge: true)),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
            })
      ],
    );
  }
}
