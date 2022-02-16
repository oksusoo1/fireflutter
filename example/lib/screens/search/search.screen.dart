import 'package:extended/extended.dart';
import 'package:fe/screens/search/search.service.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  static const String routeName = '/searchScreen';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> posts = [];

  search(value) async {
    try {
      posts = await SearchService.instance.searchPosts(value);
      setState(() {});
    } catch (e) {
      error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                onChanged: search,
                onSubmitted: search,
                decoration: InputDecoration(hintText: 'Search ...'),
              ),
              SizedBox(height: 16),
              for (final post in posts)
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Text(post.toString()),
                )
            ],
          ),
        ),
      ),
    );
  }
}
