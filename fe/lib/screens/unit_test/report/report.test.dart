import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fe/screens/unit_test/unit_test.service.dart';

class ReportTest extends StatefulWidget {
  const ReportTest({Key? key}) : super(key: key);

  @override
  State<ReportTest> createState() => _ReportTestState();
}

class _ReportTestState extends State<ReportTest> with FirestoreMixin {
  final test = UnitTestService.instance;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: runTests, child: Text('Run Report Test'));
  }

  runTests() async {
    await FirebaseAuth.instance.signOut();
    try {
      await ReportApi.instance.report(target: 'post', targetId: '...', reason: "Test reason");

      test.fail("Expect failure but succeed - Reporting without sign-in must fail.");
    } catch (e) {
      test.expect(e == ERROR_EMPTY_UID,
          "Expecting failure with ERROR_EMPTY_UID - Reporting without sign-in must fail - $e");
    }

    await test.signIn(test.b);
    String id = 'targetId-second-' + DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final report =
          await ReportApi.instance.report(target: 'post', targetId: id, reason: "Test reason");
      test.expect(report.reason == 'Test reason', 'Reported succeed - reason matches');

      // final snapshot = await reportDoc(report.id).get();

      // test.expect(snapshot.exists, 'Report document exists.');

      // final data = snapshot.data() as Map;
      // test.expect(data['targetId']! == report.targetId, 'Reported target id match.');
      // test.expect(data['reason']! == report.reason, 'Reported reason match.');
    } catch (e, st) {
      test.fail("Expect success but failed with; $e");
      debugPrintStack(stackTrace: st);
    }
  }
}
