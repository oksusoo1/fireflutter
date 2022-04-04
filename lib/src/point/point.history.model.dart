class PointHistoryModel {
  int point;
  int timestamp;
  String eventName;
  String key;

  PointHistoryModel({
    this.point = 0,
    this.timestamp = 0,
    this.eventName = '',
    this.key = '',
  });

  factory PointHistoryModel.fromJson(Map<String, dynamic> data) {
    return PointHistoryModel(
        point: data['point'] ?? 0,
        timestamp: data['timestamp'] ?? 0,
        eventName: data['eventName'] ?? '',
        key: data['key'] ?? '');
  }
}
