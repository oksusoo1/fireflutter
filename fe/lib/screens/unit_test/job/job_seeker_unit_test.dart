import 'package:flutter/material.dart';

import 'package:fireflutter/fireflutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobSeekerUnitTestController {
  late _JobSeekerUnitTestState state;
}

class JobSeekerUnitTest extends StatefulWidget {
  const JobSeekerUnitTest({Key? key, this.controller}) : super(key: key);
  final JobSeekerUnitTestController? controller;

  @override
  State<JobSeekerUnitTest> createState() => _JobSeekerUnitTestState();
}

class _JobSeekerUnitTestState extends State<JobSeekerUnitTest> with FirestoreMixin, UnitTestMixin {
  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller!.state = this;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        clearLogs();
        runTests();
      },
      child: Text('Job Seeker Unit Test'),
    );
  }

  runTests() async {
    await jobSeekerInputTest();
  }

  jobSeekerInputTest() async {
    final data = JobSeekerModel();

    await FirebaseAuth.instance.signOut();
    dynamic re = await submit(data.update());
    expect(re == "ERROR_EMPTY_UID", "Cannot edit job seeker profile if not signed in. $re");

    await signIn(a);
    re = await submit(data.update());
    expect(re == "ERROR_EMPTY_PROFICIENCY", "Error data missing. $re");

    data.proficiency = 'prof';
    re = await submit(data.update());
    expect(re == "ERROR_EMPTY_EXPERIENCES", "Error data missing. $re");

    data.experiences = '1';
    re = await submit(data.update());
    expect(re == "ERROR_EMPTY_INDUSTRY", "Error data missing. $re");

    data.industry = 'aa';
    re = await submit(data.update());
    expect(re == "ERROR_EMPTY_COMMENT", "Error data missing. $re");

    data.comment = 'some comment';
    re = await submit(data.update());
    expect(re == "ERROR_EMPTY_SINM", "Error data missing. $re");

    data.siNm = 'siNm';
    re = await submit(data.update());
    expect(re == "ERROR_EMPTY_SGGNM", "Error data missing. $re");

    /// if siNm == Sejong, it will ignore sggNm.
    data.siNm = 'Sejong';
    re = await submit(data.update());
    expect(re['id'].isNotEmpty, "Success");

    /// update again
    data.proficiency =
        "Bachelor's degree on Computer Science\nWorked for 2 years as a software developer.";
    data.experiences = "5";
    data.industry = "it";
    data.comment =
        "Can work under pressure, fluent in English.\nKnowledgable with basic web dev, php, python, java.";
    data.siNm = "Sejong";

    re = await submit(data.update());
    expect(re['id'].isNotEmpty, "Update Success.");
    expect(re['proficiency'] == data.proficiency, "Update success - Proficiency");
    expect(re['experiences'] == data.experiences, "Update success - Experience");
    expect(re['industry'] == data.industry, "Update success - Industry");
    expect(re['comment'] == data.comment, "Update success - Comment");
    expect(re['siNm'] == data.siNm, "Update success - siNm");
  }
}
