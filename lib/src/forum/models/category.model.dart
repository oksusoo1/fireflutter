import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../fireflutter.dart';

class CategoryModel with FirestoreMixin {
  CategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.order,
    required this.point,
    required this.categoryGroup,
  });

  String id;
  String title;
  String description;
  String backgroundColor;
  String foregroundColor;
  int order;
  int point;
  String categoryGroup;

  factory CategoryModel.emtpy() => CategoryModel.fromJson({}, '');
  factory CategoryModel.fromJson(dynamic data, String id) {
    return CategoryModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      backgroundColor: data['backgroundColor'] ?? '',
      foregroundColor: data['foregroundColor'] ?? '',
      order: data['order'] ?? 0,
      point: data['point'] ?? 0,
      categoryGroup: data['categoryGroup'] ?? '',
    );
  }

  /// category create
  static Future<void> create({
    required String category,
    required String title,
    required String description,
  }) async {
    final data = {
      'title': title,
      'description': description,
      'order': 0,
      'point': 0,
      'categoryGroup': '',
    };
    final categoryCol = FirebaseFirestore.instance.collection('categories');
    final doc = await categoryCol.doc(category).get();
    if (doc.exists) throw ERROR_CATEGORY_EXISTS;
    return categoryCol.doc(category).set(data);
  }

  /// Update category
  ///
  /// ```dart
  /// final cat = CategoryModel.fromJson({}, 'job');
  /// cat.update('foregroundColor', 'color').catchError(service.error);
  /// ```
  Future<void> update(String field, dynamic value) {
    return categoryDoc(id).update({field: value});
  }

  Future<void> updateBackgroundColor(String value) {
    return update('backgroundColor', value);
  }

  Future<void> updateForegroundColor(String value) {
    return update('foregroundColor', value);
  }

  Future<void> delete() {
    return categoryDoc(id).delete();
  }
}
