import 'dart:async';

import 'package:fe/screens/search/search.item.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostListScreenV2 extends StatefulWidget {
  PostListScreenV2({required this.arguments, Key? key}) : super(key: key);

  static const String routeName = '/search';
  final Map arguments;

  @override
  _PostListScreenV2State createState() => _PostListScreenV2State();
}

class _PostListScreenV2State extends State<PostListScreenV2> {
  final searchService = SearchService.instance;

  final searchEditController = TextEditingController();

  final scrollController = ScrollController();

  SearchOptionModel searchOptions = SearchOptionModel();

  List<Map<String, dynamic>> results = [];

  int hits = 0;
  bool loading = false;
  bool noMorePosts = false;

  bool get atBottom {
    return scrollController.offset > (scrollController.position.maxScrollExtent - 300);
  }

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    searchOptions.uid = widget.arguments['uid'] ?? '';
    searchOptions.index = widget.arguments['index'] ?? 'posts-and-comments';
    searchOptions.category = widget.arguments['category'] ?? '';
    searchOptions.searchKey = widget.arguments['searchKey'] ?? '';
    searchEditController.text = searchOptions.searchKey;

    searchOptions.limit = 10;
    search();

    scrollController.addListener(() {
      if (atBottom) {
        search();
      }
    });
  }

  @override
  void dispose() {
    // searchService.resetFilters();
    // searchService.resetListAndPagination(limit: 4);
    scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Screen'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: searchEditController,
              onChanged: (key) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  searchKeyword(key);
                });
              },
              decoration: InputDecoration(hintText: 'Search ...'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  hint: Text('Select Index'),
                  value: searchOptions.index,
                  items: [
                    DropdownMenuItem(child: Text('All'), value: 'posts-and-comments'),
                    DropdownMenuItem(child: Text('Posts'), value: 'posts'),
                    DropdownMenuItem(child: Text('Comments'), value: 'comments'),
                  ],
                  onChanged: (value) {
                    if (value != null) searchIndex(value);
                  },
                ),
                if (searchOptions.index != 'comments')
                  DropdownButton<String>(
                    hint: Text('Select Category'),
                    value: searchOptions.category,
                    items: [
                      DropdownMenuItem(child: Text('All'), value: ''),
                      DropdownMenuItem(child: Text('QnA'), value: 'qna'),
                      DropdownMenuItem(child: Text('Discussion'), value: 'discussion'),
                      DropdownMenuItem(child: Text('Job'), value: 'job'),
                    ],
                    onChanged: (value) => searchCategoryPosts(value ?? ''),
                  ),
                DropdownButton<String>(
                  hint: Text('Select User'),
                  value: searchOptions.uid,
                  items: [
                    DropdownMenuItem(child: Text('All'), value: ''),
                    DropdownMenuItem(child: Text('Current User'), value: UserService.instance.uid),
                    DropdownMenuItem(child: Text('User A'), value: 'jAXh1SngnafzPikQM0jpzKO3yj73'),
                    DropdownMenuItem(child: Text('User B'), value: 'Nb1NJ0d0XcQNKVEjbCj0IXN543r2'),
                  ],
                  onChanged: (value) => searchUserPosts(value ?? ''),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('No of items found: $hits'),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: results.length,
                controller: scrollController,
                itemBuilder: (c, i) {
                  return SearchItem(item: results[i]);
                },
              ),
            ),
            if (results.isEmpty && !loading) Center(child: Text('NO POSTS FOUND.')),
            if (loading) Center(child: CircularProgressIndicator())
          ],
        ),
      ),
    );
  }

  search() async {
    if (loading || noMorePosts) return;
    if (mounted) setState(() => loading = true);

    searchService.search(searchOptions).then((res) {
      if (res.hits != null) {
        if (res.hits!.length < searchOptions.limit) noMorePosts = true;
        results.addAll(res.hits!);
        hits = res.nbHits!;

        searchOptions.offset = searchOptions.limit * searchOptions.page;
        searchOptions.page += 1;
      }
    }).whenComplete(() {
      if (mounted) setState(() => loading = false);
    });
  }

  searchUserPosts(String _uid) {
    if (searchOptions.uid == _uid) return;
    searchOptions.uid = _uid;
    resetAndSearch();
  }

  searchCategoryPosts(String _category) {
    if (searchOptions.category == _category) return;
    searchOptions.category = _category;
    resetAndSearch();
  }

  searchKeyword(String _keyword) {
    searchOptions.searchKey = _keyword;
    resetAndSearch();
  }

  searchIndex(String index) {
    searchOptions.index = index;
    resetAndSearch();
  }

  resetAndSearch() {
    noMorePosts = false;
    searchOptions.limit = 4;
    searchOptions.offset = 0;
    searchOptions.page = 1;
    results = [];
    search();
  }
}
