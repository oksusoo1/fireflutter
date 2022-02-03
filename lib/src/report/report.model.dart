import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fireflutter.dart';

class ReportModel {
  String target;
  String targetId;
  String reporterUid;
  String reporteeUid;
  String reason;
  Timestamp timestamp;

  DocumentReference ref;

  ReportModel({
    required this.target,
    required this.targetId,
    required this.reporterUid,
    required this.reporteeUid,
    required this.reason,
    required this.timestamp,
    required this.ref,
  });

  factory ReportModel.fromJson(Json json, DocumentReference reference) {
    return ReportModel(
      target: json['target'],
      targetId: json['targetId'],
      reporterUid: json['reporterUid'],
      reporteeUid: json['reporteeUid'],
      reason: json['reason'] ?? '',
      timestamp: json['timestamp'],
      ref: reference,
    );
  }
}
