import '../../../fireflutter.dart';

class JobSeekerModel {
  String proficiency = '';
  String skills = '';
  String experiences = '';
  String industry = '';
  String comment = '';

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
