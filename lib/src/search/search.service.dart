import 'package:meilisearch/meilisearch.dart';

class SearchOptionModel {
  String searchKey = '';
  String index = 'posts';
  String category = '';
  String uid = '';
  int limit = 20;
  int offset = 0;
  int page = 1;
  List<String> sort = ['createdAt:desc'];
}

class SearchService {
  static SearchService? _instance;
  static SearchService get instance {
    if (_instance == null) {
      _instance = SearchService();
    }
    return _instance!;
  }

  late String _serverUrl;
  String? _apiKey;

  MeiliSearchClient get client => MeiliSearchClient(_serverUrl, _apiKey);

  // List<Map<String, dynamic>> resultList = [];
  // bool noMorePosts = false;

  /// Search options
  ///
  /// [limit] is the maximum number of documents that the search will return.
  /// [offset] is the number of documents to skip.
  /// If [sort] is not null, it will sort search results by an attribute's value.
  ///
  // String searchKey = '';
  // String index = '';
  // String category = '';
  // String uid = '';
  // int limit = 20;
  // int offset = 0;
  // int page = 1;
  // List<String> sort = ['createdAt:desc'];

  // int _hits = 0;
  // int get hits => _hits;

  init({required String serverUrl, String? apiKey}) {
    _serverUrl = serverUrl;
    _apiKey = apiKey;
  }

  /// Searches for indexed documents in the given `_serverUrl`.
  ///
  Future<SearchResult> search(SearchOptionModel opts) async {
    // if (noMorePosts) return [];
    // print('Fetching posts');
    // print('limit ---> $limit');
    // print('offset ---> $offset');
    // print('page ---> $page');

    List filters = [];
    if (opts.uid.isNotEmpty) filters.add('uid = ${opts.uid}');
    if (opts.category.isNotEmpty && opts.index != 'comments')
      filters.add('category = ${opts.category}');

    return await client.index(opts.index).search(
          opts.searchKey,
          limit: opts.limit,
          offset: opts.offset,
          sort: opts.sort,
          filter: filters,
        );

    // List<Map<String, dynamic>> _posts = [];
    // final SearchResult res = await client.index(opts.index).search(
    //       opts.searchKey,
    //       limit: opts.limit,
    //       offset: opts.offset,
    //       sort: sort,
    //       filter: filters,
    //     );

    // if (res.hits != null) {
    // if (res.hits!.length < limit) noMorePosts = true;

    // _posts = res.hits!;
    // _hits = res.nbHits ?? 0;

    ///
    // resultList.addAll(_posts);
    // offset = limit * page;
    // page += 1;
    // }

    // return _posts;
  }

  // resetFilters({String index = ''}) {
  //   uid = '';
  //   category = '';
  //   index = index;
  //   searchKey = '';
  //   sort = ['createdAt:desc'];
  // }

  // resetListAndPagination({int limit = 20}) {
  //   // noMorePosts = false;
  //   limit = limit;
  //   offset = 0;
  //   page = 1;

  //   // resultList = [];
  // }

  /// Returns a total count of documents a user owned in the given index.
  ///
  Future<int> count({
    required String uid,
    String index = 'posts',
  }) async {
    final res = await client.index(index).search(
      '',
      filter: ['uid = ' + uid],
      attributesToRetrieve: ['id'],
    );

    return res.nbHits ?? 0;
  }
}
