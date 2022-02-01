import 'package:fe/service/app.controller.dart';
import 'package:fe/service/forum.model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForumListScreen extends StatefulWidget {
  ForumListScreen({Key? key}) : super(key: key);

  @override
  State<ForumListScreen> createState() => _ForumListScreenState();
}

class _ForumListScreenState extends State<ForumListScreen> {
  final ForumModel forum = AppController.of.forum;
  @override
  void initState() {
    super.initState();
    forum.reset(category: Get.arguments['category']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(forum.title),
      ),
      body: Container(),
    );
  }
}
