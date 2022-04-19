import '../../../fireflutter.dart';

class JobSeekerModel {
  String id;
  String proficiency;
  String skills;
  String experiences;
  String industry;
  String comment;

  JobSeekerModel({
    this.id = '',
    this.proficiency = '',
    this.skills = '',
    this.experiences = '',
    this.industry = '',
    this.comment = '',
  });

  factory JobSeekerModel.fromJson(Map<String, dynamic> json, String id) {
    return JobSeekerModel(
      id: id,
      proficiency: json['proficiency'] ?? '',
      skills: json['skills'] ?? '',
      experiences: json['experiences'] ?? '',
      industry: json['industry'] ?? '',
      comment: json['comment'] ?? '',
    );
  }

  copyWith(Map<String, dynamic> data) {
    proficiency = data['proficiency'] ?? '';
    skills = data['skills'] ?? '';
    experiences = data['experiences'] ?? '0';
    industry = data['industry'] ?? '';
    comment = data['comment'] ?? '';
  }

  update() async {
    await FunctionsApi.instance.request(
      'jobUpdateProfile',
      data: updateMap,
      addAuth: true,
    );
  }

  load({required String uid}) async {
    final data = await FunctionsApi.instance.request(
      'jobGetProfile',
      data: {'uid': uid},
    );
    if (data is String) return;
    print('job profile; $data');
    copyWith(data);
    print('updateMap; $updateMap');
  }

  Map<String, dynamic> get updateMap => {
        'proficiency': proficiency,
        'skills': skills,
        'experiences': experiences,
        'industry': industry,
        'comment': comment,
      };
}
