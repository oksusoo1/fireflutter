import '../../../fireflutter.dart';
import 'package:flutter/material.dart';

class JobSeekerProfileView extends StatefulWidget {
  JobSeekerProfileView({
    Key? key,
    required this.seeker,
  }) : super(key: key);

  final JobSeekerModel seeker;

  @override
  State<JobSeekerProfileView> createState() => _JobSeekerProfileViewState();
}

class _JobSeekerProfileViewState extends State<JobSeekerProfileView> {
  final labelStyle = TextStyle(fontSize: 12, color: Colors.blueGrey);

  @override
  Widget build(BuildContext context) {
    return UserDoc(
      uid: widget.seeker.id,
      builder: (user) => Column(
        children: [
          SizedBox(height: 20),
          UserProfilePhoto(uid: user.uid, size: 100),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('First Name', style: labelStyle),
                  SizedBox(height: 5),
                  Text('${user.firstName}'),
                ],
              ),
              Column(
                children: [
                  Text('Middle Name', style: labelStyle),
                  SizedBox(height: 5),
                  Text('${user.middleName}'),
                ],
              ),
              Column(
                children: [
                  Text('Last Name', style: labelStyle),
                  SizedBox(height: 5),
                  Text('${user.lastName}'),
                ],
              ),
            ],
          ),
          Divider(height: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Gender', style: labelStyle),
              Text(user.gender == 'F' ? 'Female' : 'Male'),
              SizedBox(height: 8),
              Text('Proficiency', style: labelStyle),
              Text(widget.seeker.proficiency),
              SizedBox(height: 8),
              Text('Years of experience', style: labelStyle),
              Text(widget.seeker.experiences),
              SizedBox(height: 8),
              Text('Location', style: labelStyle),
              Text('${widget.seeker.siNm}, ${widget.seeker.sggNm}'),
              SizedBox(height: 8),
              Text('Industry', style: labelStyle),
              Text('${JobService.instance.categories[widget.seeker.industry]}'),
              SizedBox(height: 8),
              Text('Comment', style: labelStyle),
              Text('${widget.seeker.comment}'),
              SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }
}
