class ForumModel {
  String? category;
  String get title => category ?? 'No title';
  reset({
    String? category,
  }) {
    this.category = category;
  }
}
