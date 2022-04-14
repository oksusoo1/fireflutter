import 'package:cloud_firestore/cloud_firestore.dart';
import "../../../fireflutter.dart";

/// JobModel
///
class JobModel {
  JobModel({
    this.id = '',
    this.category = '',
    this.title = '',
    this.content = '',
    this.uid = '',
    this.hasPhoto = false,
    this.files = const [],
    this.deleted = false,
    this.year = 0,
    this.month = 0,
    this.day = 0,
    this.week = 0,
    createdAt,
    updatedAt,

    //
    this.companyName = '',
    this.phoneNumber = '',
    this.mobileNumber = '',
    this.email = '',
    this.detailAddress = '',
    this.aboutUs = '',
    this.numberOfHiring = '',
    this.jobDescription = '',
    this.requirement = '',
    this.duty = '',
    this.benefit = '',
    this.roadAddr = '',
    this.korAddr = '',
    this.zipNo = '',
    this.siNm = '',
    this.sggNm = '',
    this.emdNm = '',
    this.jobCategory = '',
    this.salary = '',
    this.workingDays = -1,
    this.workingHours = -1,
    this.withAccomodation = '',
    data,
  })  : data = data ?? {},
        createdAt = createdAt ?? Timestamp.now(),
        updatedAt = updatedAt ?? Timestamp.now();

  String companyName;
  String phoneNumber;
  String mobileNumber;
  String email;
  String detailAddress;
  String aboutUs;
  String numberOfHiring;
  String jobDescription;
  String requirement;
  String duty;
  String benefit;
  String roadAddr;
  String korAddr;
  String zipNo;
  String siNm;
  String sggNm;
  String emdNm;
  String jobCategory;
  String salary;
  int workingDays;
  int workingHours;
  String withAccomodation;

  /// data is the document data object.
  Json data;

  String id;
  String uid;
  String category;
  String title;
  String content;

  bool deleted;
  bool get isMine => UserService.instance.uid == uid;

  bool hasPhoto;
  List<String> files;

  int year;
  int month;
  int day;
  int week;

  Timestamp createdAt;
  Timestamp updatedAt;

  /// Get document data of map and convert it into post model
  ///
  /// If post is created via http, then it will have [id] inside `data`.
  factory JobModel.fromJson(Json data, [String? id]) {
    String content = data['content'] ?? '';

    /// If the post is created via http, the [createdAt] and [updatedAt] have different format.
    Timestamp createdAt;
    Timestamp updatedAt;
    if (data['createdAt'] is Map) {
      createdAt = Timestamp(
        data['createdAt']['_seconds'],
        data['createdAt']['_nanoseconds'],
      );
      updatedAt = Timestamp(
        data['updatedAt']['_seconds'],
        data['updatedAt']['_nanoseconds'],
      );
    } else {
      createdAt = data['createdAt'] ?? Timestamp.now();
      updatedAt = data['updatedAt'] ?? Timestamp.now();
    }

    final post = JobModel(
      id: id ?? data['id'],
      uid: data['uid'] ?? '',
      category: data['category'] ?? '',
      title: data['title'] ?? '',
      content: content,
      hasPhoto: data['hasPhoto'] ?? false,
      files: new List<String>.from(data['files'] ?? []),
      deleted: data['deleted'] ?? false,
      year: data['year'] ?? 0,
      month: data['month'] ?? 0,
      day: data['day'] ?? 0,
      week: data['week'] ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
      data: data,

      //
      companyName: data['companyName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      email: data['email'] ?? '',
      detailAddress: data['detailAddress'] ?? '',
      aboutUs: data['aboutUs'] ?? '',
      numberOfHiring: data['numberOfHiring'] ?? '',
      jobDescription: data['jobDescription'] ?? '',
      requirement: data['requirement'] ?? '',
      duty: data['duty'] ?? '',
      benefit: data['benefit'] ?? '',
      roadAddr: data['roadAddr'] ?? '',
      korAddr: data['korAddr'] ?? '',
      zipNo: data['zipNo'] ?? '',
      siNm: data['siNm'] ?? '',
      sggNm: data['sggNm'] ?? '',
      emdNm: data['emdNm'] ?? '',
      jobCategory: data['jobCategory'] ?? '',
      salary: data['salary'] ?? '',
      workingDays: data['workingDays'] ?? -1,
      workingHours: data['workingHours'] ?? -1,
      withAccomodation: data['withAccomodation'] ?? '',
    );

    return post;
  }
}
