class CategoryModel {
  CategoryModel({
    required this.id,
    required this.title,
    required this.description,
  });

  String id;
  String title;
  String description;

  factory CategoryModel.fromJson(dynamic data, String id) {
    return CategoryModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
    );
  }
}
