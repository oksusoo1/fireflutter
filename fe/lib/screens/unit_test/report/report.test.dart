import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportTestController {
  late _ReportTestState state;
}

class ReportTest extends StatefulWidget {
  const ReportTest({Key? key, required this.controller}) : super(key: key);

  final ReportTestController controller;

  @override
  State<ReportTest> createState() => _ReportTestState();
}

class _ReportTestState extends State<ReportTest> with FirestoreMixin, UnitTestMixin {
  @override
  void initState() {
    super.initState();

    widget.controller.state = this;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          clearLogs();
          runTests();
        },
        child: Text('Run Report Test'));
  }

  runTests() async {
    await FirebaseAuth.instance.signOut();
    try {
      await ReportApi.instance.report(target: 'post', targetId: '...', reason: "Test reason");

      fail("Expect failure but succeed - Reporting without sign-in must fail.");
    } catch (e) {
      expect(e == ERROR_EMPTY_UID,
          "Expecting failure with ERROR_EMPTY_UID - Reporting without sign-in must fail - $e");
    }

    await signIn(b);
    String id = 'targetId-second-' + DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final report =
          await ReportApi.instance.report(target: 'post', targetId: id, reason: "Test reason");
      expect(report.reason == 'Test reason', 'Reported succeed - reason matches');
    } catch (e, st) {
      fail("Expect success but failed with; $e");
      debugPrintStack(stackTrace: st);
    }
  }
}
