import 'package:flutter/material.dart';

import '../../../fireflutter.dart';

/// Job View
///
class JobView extends StatefulWidget {
  const JobView({
    Key? key,
    this.job,
  }) : super(key: key);

  final JobModel? job;

  @override
  State<JobView> createState() => _JobViewState();
}

class _JobViewState extends State<JobView> {
  JobModel job = JobModel.empty();

  @override
  initState() {
    super.initState();
    job = widget.job!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RichText(
            text: TextSpan(children: [
          TextSpan(
              text: "Job recruitment from ",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              )),
          TextSpan(
              text: job.companyName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )),
        ])),
        SizedBox(height: 15),
        JobViewItem(
          value: job.companyName,
          label: "Company Name",
        ),
        JobViewItem(
          value: job.mobileNumber,
          label: "Mobile number",
        ),
        JobViewItem(
          value: job.phoneNumber,
          label: "Phone number",
        ),
        JobViewItem(
          value: job.email,
          label: "Email",
        ),
        JobViewItem(
          value: job.aboutUs,
          label: "About Us",
        ),
        JobViewItem(
          value: job.roadAddr,
          label: "Road Address",
        ),
        JobViewItem(
          value: job.detailAddress,
          label: "Detail Address",
        ),
        SizedBox(height: 15),
        Text('Job details',
            style: TextStyle(fontSize: 16, color: Colors.black)),
        SizedBox(height: 10),
        JobViewItem(
          value: JobService.instance.categories[job.jobCategory] ?? '',
          label: "Job Category",
        ),
        JobViewItem(
          value: job.workingDays == 0
              ? "Flexible"
              : job.workingDays > 0
                  ? '${job.workingDays} days'
                  : '',
          label: "Working Days",
        ),
        JobViewItem(
          value: job.workingHours == 0
              ? "Flexible"
              : job.workingHours > 0
                  ? '${job.workingHours} hour'
                  : '',
          label: "Working Hours",
        ),
        JobViewItem(
          value: "${job.salary} Won",
          label: "Salary",
        ),
        JobViewItem(
          value: "${job.numberOfHiring} available slot",
          label: "Vacant",
        ),
        JobViewItem(
          value: job.description,
          label: "Descriptions",
        ),
        JobViewItem(
          value: job.requirement,
          label: "Requirements",
        ),
        JobViewItem(
          key: UniqueKey(),
          value: job.requirement,
          label: "Requirements and qualifications",
        ),
        JobViewItem(
          key: UniqueKey(),
          value: job.duty,
          label: "Duties and responsibilities",
        ),
        JobViewItem(
          key: UniqueKey(),
          value: job.benefit,
          label: "benefits(free meals, dormitory, transporation, etc)",
        ),
        JobViewItem(
          value: job.withAccomodation == 'Y' ? "Yes" : 'No',
          label: "Accomodation",
        ),
      ],
    );
  }
}

class JobViewItem extends StatelessWidget {
  const JobViewItem({
    Key? key,
    required this.value,
    required this.label,
  }) : super(key: key);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 24),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 8),
        Text(value),
      ],
    );
  }
}
