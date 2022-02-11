import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fireflutter.dart';

class CategoryService with FirestoreMixin {
  static CategoryService? _instance;
  static CategoryService get instance {
    _instance ??= CategoryService();
    return _instance!;
  }

  List<CategoryModel> categories = [];

  /// Returns [categories]
  ///
  /// Note if categoris are not fetched from firestore, then it will fetch and
  /// return [categories].
  /// Note if categories are already fetched, then it will not re-fetch
  /// categoreis.
  Future<List<CategoryModel>> getCategories() async {
    if (categories.length > 0) return categories;
    return await loadCategories();
  }

  /// Loads categories and save it into [categories], and return it.
  Future<List<CategoryModel>> loadCategories() async {
    final querySnapshot = await categoryCol.orderBy('title').get();
    if (querySnapshot.size == 0) return [];

    categories = [];

    for (DocumentSnapshot doc in querySnapshot.docs) {
      categories.add(CategoryModel.fromJson(doc.data(), doc.id));
    }
    return categories;
  }
}
