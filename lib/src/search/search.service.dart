import 'package:meilisearch/meilisearch.dart';

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

  List<Map<String, dynamic>> resultList = [];

  /// Search options
  ///
  /// [limit] is the maximum number of documents that the search will return.
  /// [offset] is the number of documents to skip.
  /// If [sort] is not null, it will sort search results by an attribute's value.
  ///
  String searchKey = '';
  String index = '';
  String category = '';
  String uid = '';
  int limit = 20;
  int offset = 0;
  int page = 1;
  List<String> sort = ['timestamp:desc'];

  init({required String serverUrl, String? apiKey}) {
    _serverUrl = serverUrl;
    _apiKey = apiKey;
  }

  /// Searches for indexed documents in the given `_serverUrl`.
  ///
  Future<List<Map<String, dynamic>>> search() async {
    print('limit ---> $limit');
    print('offset ---> $offset');
    print('page ---> $page');

    List filters = [];
    if (uid.isNotEmpty) filters.add('uid = $uid');
    if (category.isNotEmpty) filters.add('category = $category');
    // if (extrafilters.isNotEmpty) _filters.addAll(extrafilters);

    List<Map<String, dynamic>> _posts = [];
    final SearchResult res = await client.index(index).search(
          searchKey,
          limit: limit,
          offset: offset,
          sort: sort,
          filter: filters,
        );

    if (res.hits != null) {
      _posts = res.hits!;
      resultList.addAll(_posts);
      offset = limit * page;
      page += 1;
    }

    return _posts;
  }

  ///
  /// ADMIN FUNCTIONS
  ///

  /// Updates filterable attributes for an index.
  ///
  Future updateIndexSearchSettings({
    required String index,
    List<String>? searchables,
    List<String>? sortables,
    List<String>? filterables,
  }) async {
    /// TODO: check if admin.
    /// if (!UserService.instance.user.isAdmin) throw 'YOU_ARE_NOT_ADMIN';

    return SearchService.instance.client.index(index).updateSettings(
          IndexSettings(
            searchableAttributes: searchables,
            sortableAttributes: sortables,
            filterableAttributes: filterables,
            // rankingRules: [],
            // distinctAttribute: '', default to index
            // displayedAttributes: ['*'], // default to '*' (all)
            // stopWords: [],
            // synonyms: { 'word': ['other', 'logan'] },
          ),
        );
  }

  resetFilters() {
    uid = '';
    index = '';
    category = '';
    searchKey = '';
    sort = ['timestamp:desc'];
  }

  resetListAndPagination({int limit = 20}) {
    limit = limit;
    offset = 0;
    page = 1;

    resultList = [];
  }
}
