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
  });

  String id;
  String title;
  String description;
  String backgroundColor;
  String foregroundColor;
  int order;

  factory CategoryModel.emtpy() => CategoryModel.fromJson({}, '');
  factory CategoryModel.fromJson(dynamic data, String id) {
    return CategoryModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      backgroundColor: data['backgroundColor'] ?? '',
      foregroundColor: data['foregroundColor'] ?? '',
      order: data['order'] ?? 0,
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
    };
    final categoryCol = FirebaseFirestore.instance.collection('categories');
    final doc = await categoryCol.doc(category).get();
    if (doc.exists) throw ERROR_CATEGORY_EXISTS;
    return categoryCol.doc(category).set(data);
  }

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
