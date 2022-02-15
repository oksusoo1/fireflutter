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

  init({required String serverUrl, String? apiKey}) {
    _serverUrl = serverUrl;
    _apiKey = apiKey;
  }

  Future<SearchResult> search(String index, String searchKey) async {
    return client.index(index).search(searchKey);
  }

  Future<List<Map<String, dynamic>>> searchPosts(String key) async {
    final result = await search('posts', key);
    if (result.hits == null) return [];

    /// 20 by default
    print('Search limit ===> ${result.limit}');
    print('No of items ===> ${result.nbHits}');
    print('Skipped items ===> ${result.offset}');
    return result.hits!;
  }
}
