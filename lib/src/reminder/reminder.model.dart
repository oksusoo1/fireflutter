class ReminderModel {
  String link;
  String title;
  String content;
  String imageUrl;
  ReminderModel({
    required this.link,
    required this.title,
    required this.content,
    required this.imageUrl,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> data) {
    return ReminderModel(
      link: data['link'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
