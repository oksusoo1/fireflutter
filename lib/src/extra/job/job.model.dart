import 'package:fireflutter/fireflutter.dart';

class JobInfoModel {
  JobInfoModel({
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
  });

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

  factory JobInfoModel.fromJson(Json json) {
    final int _days =
        json['workingDays'] is int ? json['workingDays'] : int.parse(json['workingDays'] ?? '-1');
    final int _hours = json['workingHours'] is int
        ? json['workingHours']
        : int.parse(json['workingHours'] ?? '-1');

    return JobInfoModel(
      companyName: json['companyName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      email: json['email'] ?? '',
      detailAddress: json['detailAddress'] ?? '',
      aboutUs: json['aboutUs'] ?? '',
      numberOfHiring: json['numberOfHiring'] ?? '',
      jobDescription: json['jobDescription'] ?? '',
      requirement: json['requirement'] ?? '',
      duty: json['duty'] ?? '',
      benefit: json['benefit'] ?? '',
      jobCategory: json['jobCategory'] ?? '',
      salary: json['salary'] ?? '',
      workingDays: _days,
      workingHours: _hours,
      withAccomodation: json['withAccomodation'] ?? '',
      roadAddr: json['roadAddr'] ?? '',
      korAddr: json['korAddr'] ?? '',
      zipNo: json['zipNo'] ?? '',
      siNm: json['siNm'] ?? '',
      sggNm: json['sggNm'] ?? '',
      emdNm: json['emdNm'] ?? '',
    );
  }

  factory JobInfoModel.empty() {
    return JobInfoModel(
      companyName: '',
      phoneNumber: '',
      mobileNumber: '',
      email: '',
      detailAddress: '',
      aboutUs: '',
      numberOfHiring: '',
      jobDescription: '',
      requirement: '',
      duty: '',
      benefit: '',
      jobCategory: '',
      salary: '',
      workingDays: -1,
      workingHours: -1,
      withAccomodation: '',
    );
  }

  Map<String, dynamic> get toMap => {
        'companyName': companyName,
        'phoneNumber': phoneNumber,
        'mobileNumber': mobileNumber,
        'email': email,
        'detailAddress': detailAddress,
        'aboutUs': aboutUs,
        'numberOfHiring': numberOfHiring,
        'jobDescription': jobDescription,
        'requirement': requirement,
        'duty': duty,
        'benefit': benefit,
        'jobCategory': jobCategory,
        'salary': salary,
        'workingDays': workingDays,
        'workingHours': workingHours,
        'withAccomodation': withAccomodation,
        'roadAddr': roadAddr,
        'korAddr': korAddr,
        'zipNo': zipNo,
        'siNm': siNm,
        'sggNm': sggNm,
        'emdNm': emdNm,
      };

  AddressModel get address => AddressModel.fromMap(toMap);
}
