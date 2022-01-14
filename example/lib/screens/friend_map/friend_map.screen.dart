import 'package:extended/extended.dart';
import 'package:fe/services/config.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FriendMapScreen extends StatelessWidget {
  const FriendMapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Map'),
      ),
      body: FriendMap(
        googleApiKey: Config.gcpApiKeyWithRestriction,
        error: error,
      ),
    );
  }
}
