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

  /// Searches for indexed documents in the given `_serverUrl`.
  ///
  /// [limit] is the maximum number of documents that the search will return.
  /// [offset] is the number of documents to skip.
  /// If [sort] is not null, it will sort search results by an attribute's value.
  /// If [filter] is not null, it will filter search results by an attribute's value.
  /// 
  Future<SearchResult> search(
    String index,
    String searchKey, {
    String? uid,
    int? limit = 20,
    int? offset,
    List<String>? sort,
    List<dynamic> filter = const [],
  }) async {
    if (uid != null && uid.isNotEmpty) {
      filter = [...filter, 'uid = $uid'];
    }
    return client.index(index).search(
          searchKey,
          limit: limit,
          offset: offset,
          sort: sort,
          filter: filter,
        );
  }

  Future<List<PostModel>> searchPosts(
    String key, {
    String? uid,
    int? limit,
    int? offset,
    List<String>? sort,
    List<dynamic> filter = const [],
  }) async {
    if (uid != null && uid.isNotEmpty) {
      filter = [...filter, 'uid = $uid'];
    }

    final result = await search(
      'posts',
      key,
      limit: limit,
      offset: offset,
      sort: sort,
      filter: filter,
    );
    if (result.hits == null) return [];
    return result.hits!.map((data) => PostModel.fromJson(data, data['id'])).toList();
  }

  Future<List<CommentModel>> searchComments(
    String key, {
    String? uid,
    int? limit,
    int? offset,
    List<String>? sort,
    List<dynamic> filter = const [],
  }) async {
    if (uid != null && uid.isNotEmpty) {
      filter = [...filter, 'uid = $uid'];
    }

    final result = await search('comments', key, limit: limit, offset: offset, sort: sort);
    if (result.hits == null) return [];
    return result.hits!.map((data) => CommentModel.fromJson(data, id: data['id'])).toList();
  }
}
