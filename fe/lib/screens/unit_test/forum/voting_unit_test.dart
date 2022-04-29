import 'package:flutter/material.dart';

import 'package:fireflutter/fireflutter.dart';

class VoteUnitTestController {
  late _VoteUnitTestState state;
}

class VoteUnitTest extends StatefulWidget {
  const VoteUnitTest({Key? key, this.controller}) : super(key: key);
  final VoteUnitTestController? controller;

  @override
  State<VoteUnitTest> createState() => _VoteUnitTestState();
}

class _VoteUnitTestState extends State<VoteUnitTest> with UnitTestMixin, FirestoreMixin {
  // final test = UnitTestService.instance;

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
      child: Text('Run Voting Unit Test'),
    );
  }

  runTests() async {
    await signIn(a);
    final post = await PostApi.instance.create(category: 'qna');
    final postPath = postDoc(post.id).path;

    await feed(postPath, 'like');
    dynamic data = await postDoc(post.id).get();
    expect(data['like'] == 1, 'like incremented to 1 (user A liked)');

    await feed(postPath, 'like');
    data = await postDoc(post.id).get();
    expect(data['like'] == 0, 'like decremented to 0 (user A liked)');

    await signIn(b);
    await feed(postPath, 'like');
    data = await postDoc(post.id).get();
    expect(data['like'] == 1, 'like incremented to 1 (user B liked)');

    await signIn(a);
    await feed(postPath, 'like');
    data = await postDoc(post.id).get();
    expect(data['like'] == 2, 'like incremented to 2 (user A liked)');

    await feed(postPath, 'dislike');
    data = await postDoc(post.id).get();
    expect(data['like'] == 1, 'like decremented to 1 (user A disliked)');
    expect(data['dislike'] == 1, 'dislike incremented to 1 (user A disliked)');

    await signIn(b);
    await feed(postPath, 'dislike');
    data = await postDoc(post.id).get();
    expect(data['like'] == 0, 'like decremented to 0 (user B disliked)');
    expect(data['dislike'] == 2, 'dislike incremented to 2 (user B disliked)');

    /// cleanup
    await signIn(a);
    await post.delete();
  }
}
