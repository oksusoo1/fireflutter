import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fireflutter.dart';

class CategoryService with FirestoreMixin {
  static CategoryService? _instance;
  static CategoryService get instance {
    _instance ??= CategoryService();
    return _instance!;
  }

  List<CategoryModel> categories = [];

  /// Returns cached categories.
  ///
  /// Note if categoris are not fetched from firestore, then it will fetch and
  /// return [categories].
  /// Note if categories are already fetched, then it will return memory cached
  /// categories, instead of fetcing again.
  ///
  /// If [hideHiddenCategory] is set to true, then it will not return categories whose order is -1.
  ///
  /// Note that, this is async call. So, it should be used with `setState`
  /// ```dart
  /// ```
  Future<List<CategoryModel>> getCategories(
      {bool hideHiddenCategory: false}) async {
    if (categories.length == 0) await loadCategories();
    if (hideHiddenCategory)
      return categories.where((cat) => cat.order != -1).toList();
    else
      return categories;
  }

  /// Loads categories and save it into [categories], and return it.
  Future<List<CategoryModel>> loadCategories() async {
    final querySnapshot =
        await categoryCol.orderBy('order', descending: true).get();
    if (querySnapshot.size == 0) return [];

    categories = [];

    for (DocumentSnapshot doc in querySnapshot.docs) {
      categories.add(CategoryModel.fromJson(doc.data(), doc.id));
    }
    return categories;
  }
}
