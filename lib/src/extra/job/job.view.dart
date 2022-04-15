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
  final _formKey = GlobalKey<FormState>();
  final detailedAddress = TextEditingController();

  AddressModel? address;

  JobModel job = JobModel.empty();

  @override
  initState() {
    super.initState();
    init();
  }

  init() {
    job = widget.job!;
    address = AddressModel.fromMap(job.toUpdate);
    detailedAddress.text = job.detailAddress;
    addJobAddress(address!);
  }

  /// Display popup and let user choose address
  getAddress() async {
    final _address = await JobService.instance.showAddressPopupWindow(context);
    if (_address == null) return;
    address = _address;
    detailedAddress.clear();
    setState(() {});
  }

  addJobAddress(AddressModel addr) {
    job.roadAddr = addr.roadAddr;
    job.korAddr = addr.korAddr;
    job.zipNo = addr.zipNo;
    job.siNm = addr.siNm;
    job.sggNm = addr.sggNm;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Company details',
              style: TextStyle(fontSize: 16, color: Colors.black)),
          SizedBox(height: 15),
          TextFormField(
            readOnly: true,
            initialValue: job.companyName,
            decoration: InputDecoration(
              labelText: "Company Name",
            ),
          ),
          TextFormField(
            readOnly: true,
            initialValue: job.mobileNumber,
            decoration: InputDecoration(
              labelText: "Mobile number",
            ),
          ),
          TextFormField(
            readOnly: true,
            initialValue: job.phoneNumber,
            decoration: InputDecoration(
              labelText: "Phone number",
            ),
          ),
          TextFormField(
            readOnly: true,
            initialValue: job.email,
            decoration: InputDecoration(
              labelText: "Email",
            ),
          ),
          TextFormField(
            readOnly: true,
            initialValue: job.aboutUs,
            decoration: InputDecoration(
              labelText: "About Use",
            ),
          ),
          SizedBox(height: 15),
          Text('Job details',
              style: TextStyle(fontSize: 16, color: Colors.black)),
          SizedBox(height: 10),
          TextFormField(
            readOnly: true,
            initialValue: JobService.instance.categories[job.jobCategory] ?? '',
            decoration: InputDecoration(
              labelText: "Job Category",
            ),
          ),
          TextFormField(
            readOnly: true,
            initialValue: job.workingDays == 0
                ? "Flexible"
                : job.workingDays > 0
                    ? '${job.workingDays} days'
                    : '',
            decoration: InputDecoration(
              labelText: "Working Days",
            ),
          ),
          TextFormField(
            readOnly: true,
            initialValue: job.workingHours == 0
                ? "Flexible"
                : job.workingHours > 0
                    ? '${job.workingHours} hour'
                    : '',
            decoration: InputDecoration(
              labelText: "Working Hours",
            ),
          ),
          TextFormField(
            readOnly: true,
            initialValue: "${job.salary} Won",
            decoration: InputDecoration(
              labelText: "Salary",
            ),
          ),
          TextFormField(
            readOnly: true,
            initialValue: "${job.numberOfHiring} available slot",
            decoration: InputDecoration(
              labelText: "Vacant",
            ),
          ),
          TextFormField(
            readOnly: true,
            initialValue: job.description,
            decoration: InputDecoration(
              labelText: "Descriptions",
            ),
          ),
          TextFormField(
            readOnly: true,
            initialValue: job.requirement,
            decoration: InputDecoration(
              labelText: "Requirements",
            ),
          ),
          TextFormField(
            key: UniqueKey(),
            initialValue: job.requirement,
            autovalidateMode: AutovalidateMode.always,
            decoration: InputDecoration(
              labelText: "Requirements and qualifications",
            ),
            readOnly: true,
          ),
          TextFormField(
            key: UniqueKey(),
            initialValue: job.duty,
            autovalidateMode: AutovalidateMode.always,
            decoration: InputDecoration(
              labelText: "Duties and responsibilities",
            ),
            readOnly: true,
          ),
          TextFormField(
            key: UniqueKey(),
            initialValue: job.benefit,
            autovalidateMode: AutovalidateMode.always,
            decoration: InputDecoration(
              labelText: "benefits(free meals, dormitory, transporation, etc)",
            ),
            readOnly: true,
          ),
          TextFormField(
            readOnly: true,
            initialValue: job.withAccomodation == 'Y' ? "Yes" : 'No',
            decoration: InputDecoration(
              labelText: "Accomodation",
            ),
          ),
        ],
      ),
    );
  }
}
