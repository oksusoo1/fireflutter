import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ReportListingModel {
  String target;
  String targetId;
  ReportListingModel({
    required this.target,
    required this.targetId,
  });
  Map<String, dynamic> toJson() {
    return {
      'target': target,
      'targetId': targetId,
      'timestamp': ServerValue.timestamp, //
    };
  }
}

class ReportModel {
  String target;
  String targetId;
  String reporterUid;
  String reporterDisplayName;
  String reporteeUid;
  String reporteeDisplayName;

  ReportModel({
    required this.target,
    required this.targetId,
    required this.reporterUid,
    required this.reporterDisplayName,
    required this.reporteeUid,
    required this.reporteeDisplayName,
  });
  Map<String, dynamic> toJson() {
    return {
      'target': target,
      'targetId': targetId,
      'timestamp': ServerValue.timestamp, //

      'reporterUid': reporterUid,
      'reporterDisplayName': reporterDisplayName,
      'reporteeUid': reporteeUid,
      'reporteeDisplayName': reporteeDisplayName,
    };
  }
}

/// See readme.md
class ReportService {
  static ReportService? _instance;
  static ReportService get instance {
    _instance ??= ReportService();
    return _instance!;
  }

  FirebaseFirestore get db => FirebaseFirestore.instance;
  CollectionReference get reportListingCol => db.collection('report-listing');
  CollectionReference get reportCol => db.collection('report');

  /// On success, return Future<void>
  /// On error, FirebaseException will be thrown
  Future<void> report({
    required String target,
    required String targetId,
    required reporterUid,
    required reporterDisplayName,
    required reporteeUid,
    required reporteeDisplayName,
  }) async {
    await reportListingCol.add(
      ReportModel(
        target: 'post',
        targetId: 'post_1',
        reporterUid: reporterUid,
        reporterDisplayName: reporterDisplayName,
        reporteeUid: reporteeUid,
        reporteeDisplayName: reporteeDisplayName,
      ).toJson(),
    );

    await reportListingCol.add(
      ReportListingModel(
        target: 'post',
        targetId: 'post_1',
      ).toJson(),
    );
  }
}
