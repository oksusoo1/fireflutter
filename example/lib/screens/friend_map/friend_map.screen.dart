import 'package:extended/extended.dart';
import 'package:fe/service/config.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FriendMapScreen extends StatefulWidget {
  const FriendMapScreen({required this.arguments, Key? key}) : super(key: key);

  static const String routeName = '/friendMap';
  final Map arguments;

  @override
  State<FriendMapScreen> createState() => _FriendMapScreenState();
}

class _FriendMapScreenState extends State<FriendMapScreen> {
  double get latitude => toDouble(widget.arguments['latitude']);
  double get longitude => toDouble(widget.arguments['longitude']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Map'),
      ),
      body: FriendMap(
        googleApiKey: Config.gcpApiKeyWithRestriction,
        otherUserUid: widget.arguments['uid'],
        latitude: latitude,
        longitude: longitude,
        error: error,
      ),
    );
  }
}
