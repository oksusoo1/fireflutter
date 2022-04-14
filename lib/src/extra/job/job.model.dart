import '../../../fireflutter.dart';

class JobModel {
  JobModel({
    this.id = '',
    this.companyName = '',
    this.phoneNumber = '',
    this.mobileNumber = '',
    this.email = '',
    this.detailAddress = '',
    this.aboutUs = '',
    this.numberOfHiring = '',
    this.description = '',
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
    this.files = const [],
  });

  String id;
  String companyName;
  String phoneNumber;
  String mobileNumber;
  String email;
  String detailAddress;
  String aboutUs;
  String numberOfHiring;
  String description;
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
  List<String> files;

  factory JobModel.fromJson(Json json, [String id = '']) {
    final int _days =
        json['workingDays'] is int ? json['workingDays'] : int.parse(json['workingDays'] ?? '-1');
    final int _hours = json['workingHours'] is int
        ? json['workingHours']
        : int.parse(json['workingHours'] ?? '-1');

    return JobModel(
      id: json['id'] ?? id,
      companyName: json['companyName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      email: json['email'] ?? '',
      detailAddress: json['detailAddress'] ?? '',
      aboutUs: json['aboutUs'] ?? '',
      numberOfHiring: json['numberOfHiring'] ?? '',
      description: json['description'] ?? '',
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
      files: List<String>.from(json['files'] ?? []),
    );
  }

  factory JobModel.empty() {
    return JobModel(
      id: '',
      companyName: '',
      phoneNumber: '',
      mobileNumber: '',
      email: '',
      detailAddress: '',
      aboutUs: '',
      numberOfHiring: '',
      description: '',
      requirement: '',
      duty: '',
      benefit: '',
      jobCategory: '',
      salary: '',
      workingDays: -1,
      workingHours: -1,
      withAccomodation: '',
      files: [],
    );
  }

  Map<String, dynamic> get toCreate => {
        'companyName': companyName,
        'phoneNumber': phoneNumber,
        'mobileNumber': mobileNumber,
        'email': email,
        'detailAddress': detailAddress,
        'aboutUs': aboutUs,
        'numberOfHiring': numberOfHiring,
        'description': description,
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
        'files': files,
      };

  Map<String, dynamic> get toUpdate => {
        'id': id,
        'companyName': companyName,
        'phoneNumber': phoneNumber,
        'mobileNumber': mobileNumber,
        'email': email,
        'detailAddress': detailAddress,
        'aboutUs': aboutUs,
        'numberOfHiring': numberOfHiring,
        'description': description,
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
        'files': files,
      };

  // AddressModel get address => AddressModel.fromMap(toMap);

  @override
  String toString() {
    return '''JobModel($toUpdate)''';
  }
}
