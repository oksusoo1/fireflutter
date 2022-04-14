class JobListOptionModel {
  String siNm = '';
  String sggNm = '';
  String jobCategory = '';
  int workingHours = -1;
  int workingDays = -1;
  String accomodation = '';
  String salary = '';
  String sort = '';

  get toMap {
    return {
      'siNm': siNm,
      'sggNm': sggNm,
      'jobCategory': jobCategory,
      'workingHours': workingHours,
      'workingDays': workingDays,
      'accomodation': accomodation,
      'salary': salary,
      'sort': sort,
    };
  }

  @override
  String toString() {
    return '''JobListOptionModel($toMap)''';
  }
}
