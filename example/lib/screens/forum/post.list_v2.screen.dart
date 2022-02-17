import 'package:extended/extended.dart';
import 'package:fe/service/search.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostListScreenV2 extends StatefulWidget {
  PostListScreenV2({required this.arguments, Key? key}) : super(key: key);

  static const String routeName = '/postListV2';
  final Map arguments;

  @override
  _PostListScreenV2State createState() => _PostListScreenV2State();
}

class _PostListScreenV2State extends State<PostListScreenV2> {
  List<PostModel> posts = [];

  final searchEditController = TextEditingController();

  String? uid;
  String? currentCategory;
  String? searchKey;

  @override
  void initState() {
    super.initState();

    uid = widget.arguments['uid'];
    currentCategory = widget.arguments['category'];
    searchKey = widget.arguments['searchKey'];
    searchEditController.text = searchKey ?? '';

    search();
  }

  search() async {
    try {
      posts = await SearchService.instance.searchPosts(
        uid: uid,
        category: currentCategory,
        searchKey: searchKey,
      );
      // print(posts);
      setState(() {});
    } catch (e) {
      error(e);
    }
  }

  searchUserPosts(String _uid) {
    uid = _uid;
    search();
  }

  searchCategoryPosts(String _category) {
    currentCategory = _category;
    search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post listing with meilisearch'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Current Search Params'),
              SizedBox(height: 8),
              Text('  UID: $uid'),
              Text('  Category: $currentCategory'),
              Text('  Search Key: $searchKey'),
              Divider(),
              Wrap(
                children: [
                  ElevatedButton(onPressed: () => searchUserPosts(''), child: Text('All Users')),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => searchUserPosts('user_aaa'),
                    child: Text('User A'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => searchUserPosts('user_bbb'),
                    child: Text('User B'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => searchUserPosts('user_ccc'),
                    child: Text('User C'),
                  ),
                ],
              ),
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed: () => searchCategoryPosts(''),
                    child: Text('All Category'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => searchCategoryPosts('qna'),
                    child: Text('QnA'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => searchCategoryPosts('discussion'),
                    child: Text('Discussion'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => searchCategoryPosts('job'),
                    child: Text('Job'),
                  ),
                ],
              ),
              TextField(
                onChanged: (text) {
                  searchKey = text;
                  search();
                },
                decoration: InputDecoration(hintText: 'Search ...'),
              ),
              SizedBox(height: 16),
              for (final post in posts)
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("ID: ${post.id}"),
                      Text("UID: ${post.uid}"),
                      Text("Category: ${post.category}"),
                      Text("Title: ${post.title}"),
                      Text("Content: ${post.displayContent}"),
                      ShortDate(post.timestamp.millisecondsSinceEpoch),
                    ],
                  ),
                ),
              if (posts.isEmpty) Center(child: Text('NO POSTS FOUND.'))
            ],
          ),
        ),
      ),
    );
  }
}
