import 'package:extended/extended.dart';
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
  final searchService = SearchService.instance;

  final searchEditController = TextEditingController();

  final scrollController = ScrollController();

  bool loading = false;
  bool noMorePosts = false;

  bool get atBottom {
    return scrollController.offset > (scrollController.position.maxScrollExtent - 300);
  }

  @override
  void initState() {
    super.initState();

    searchService.uid = widget.arguments['uid'] ?? '';
    searchService.index = widget.arguments['index'] ?? 'posts';
    searchService.category = widget.arguments['category'] ?? '';
    searchService.searchKey = widget.arguments['searchKey'] ?? '';
    searchEditController.text = searchService.searchKey;

    searchService.limit = 4;
    search();

    scrollController.addListener(() {
      if (atBottom) {
        search();
      }
    });
  }

  @override
  void dispose() {
    searchService.resetFilters();
    searchService.resetListAndPagination(limit: 4);
    scrollController.dispose();
    super.dispose();
  }

  search() async {
    if (loading || noMorePosts) return;
    if (mounted) setState(() => loading = true);
    print('Fetching posts');

    try {
      final res = await searchService.search();
      if (res.length < searchService.limit) noMorePosts = true;
    } catch (e) {
      error(e);
    }
    if (mounted) setState(() => loading = false);
  }

  searchUserPosts(String _uid) {
    if (searchService.uid == _uid) return;
    searchService.uid = _uid;
    resetAndSearch();
  }

  searchCategoryPosts(String _category) {
    if (searchService.category == _category) return;
    searchService.category = _category;
    resetAndSearch();
  }

  searchKeyword(String _keyword) {
    searchService.searchKey = _keyword;
    resetAndSearch();
  }

  resetAndSearch() {
    noMorePosts = false;
    searchService.resetListAndPagination(limit: 4);
    search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post listing with meilisearch'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Current Search Params'),
            SizedBox(height: 8),
            Text('  UID: ${searchService.uid}'),
            Text('  Category: ${searchService.category}'),
            Text('  Search Key: ${searchService.searchKey}'),
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
              onChanged: searchKeyword,
              decoration: InputDecoration(hintText: 'Search ...'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                separatorBuilder: (c, i) => Divider(),
                itemCount: searchService.resultList.length,
                controller: scrollController,
                itemBuilder: (c, i) {
                  final PostModel post = PostModel.fromJson(
                    searchService.resultList[i],
                    searchService.resultList[i]['id'],
                  );
                  return Container(
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
                  );
                },
              ),
            ),
            if (searchService.resultList.isEmpty) Center(child: Text('NO POSTS FOUND.'))
          ],
        ),
      ),
    );
  }
}
