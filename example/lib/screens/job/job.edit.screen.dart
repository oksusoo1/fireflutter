import 'package:fe/screens/forum/forum.mixin.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class JobEditScreen extends StatefulWidget {
  const JobEditScreen({required this.arguments, Key? key}) : super(key: key);
  static final String routeName = '/jobEdit';

  final Map arguments;

  @override
  State<JobEditScreen> createState() => _JobEditScreenState();
}

class _JobEditScreenState extends State<JobEditScreen> with FirestoreMixin, ForumMixin {
  final companyName = TextEditingController();
  final phoneNumber = TextEditingController();
  final mobileNumber = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Edit'),
      ),
      body: Column(
        children: [
          Text('Create a job opening'),
          Text(
            'Company name, phone number, email address, website, employment type(full time, partime), job category(industry), job title(position), work hours, province, city, about us, number of recruitment(채용인원), job description(details of things to do), requirements and qualifications, duties and responsibilities, salary, benefits, how many meals provided, dormitory, ',
          ),
          TextField(
            controller: companyName,

            // decoration: InputDecoration(hintText: 'Company name', floatingLabelBehavior: FloatingLabelAlignment.start),
          ),
          TextField(controller: mobileNumber),
          TextField(controller: phoneNumber),
        ],
      ),
    );
  }
}
