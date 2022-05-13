import 'package:meilisearch/meilisearch.dart';

/// Search options
///
/// [limit] is the maximum number of documents that the search will return.
/// [offset] is the number of documents to skip.
/// If [sort] is not null, it will sort search results by an attribute's value.
class SearchOptionModel {
  String searchKey = '';
  String index = 'posts';
  String category = '';
  String uid = '';
  int limit = 20;
  int offset = 0;
  int page = 1;
  List<String> filter = [];
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

  init({required String serverUrl, String? apiKey}) {
    _serverUrl = serverUrl;
    _apiKey = apiKey;
  }

  /// Searches for indexed documents in the given `_serverUrl`.
  ///
  Future<SearchResult> search(SearchOptionModel opts) async {
    // print('Fetching posts');
    // print('options ---> ${opts.toString()}');

    List filters = opts.filter;
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
  }

  /// Returns a total count of documents a user owned in the given index.
  ///
  /// ! Attention - move this to cloud functions.
  Future<int> count({
    required String uid,
    String index = 'posts',
  }) async {
    uid = uid.replaceAll('@', '');
    final res = await client.index(index).search(
      '',
      filter: ['uid = ' + uid],
      attributesToRetrieve: ['id'],
    );

    return res.nbHits ?? 0;
  }
}
