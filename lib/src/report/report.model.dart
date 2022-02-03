import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fireflutter.dart';

class ReportModel {
  String target;
  String targetId;
  String reporterUid;
  String reporteeUid;
  String reason;
  Timestamp timestamp;

  ReportModel({
    required this.target,
    required this.targetId,
    required this.reporterUid,
    required this.reporteeUid,
    required this.reason,
    required this.timestamp,
  });

  factory ReportModel.fromJson(Json json) {
    return ReportModel(
      target: json['target'],
      targetId: json['targetId'],
      reporterUid: json['reporterUid'],
      reporteeUid: json['reporteeUid'],
      reason: json['reason'] ?? '',
      timestamp: json['timestamp'],
    );
  }
}
