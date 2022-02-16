import 'package:fireflutter/fireflutter.dart';
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

  Future<SearchResult> search(
    String index,
    String searchKey, {
    int? limit = 20,
    int? offset,
    List<String>? sort,
  }) async {
    return client.index(index).search(
          searchKey,
          limit: limit,
          offset: offset,
          sort: sort,
        );
  }

  Future<List<PostModel>> searchPosts(
    String key, {
    int? limit,
    int? offset,
    List<String>? sort,
  }) async {
    final result = await search('posts', key, limit: limit, offset: offset, sort: sort);
    if (result.hits == null) return [];
    return result.hits!.map((e) => PostModel.fromJson(e, e['id'])).toList();
  }

  Future<List<Map<String, dynamic>>> searchComments(
    String key, {
    int? limit,
    int? offset,
    List<String>? sort,
  }) async {
    final result = await search('comments', key, limit: limit, offset: offset, sort: sort);
    if (result.hits == null) return [];
    return result.hits!;
  }
}
