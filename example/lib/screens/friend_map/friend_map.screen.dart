import 'package:extended/extended.dart';
import 'package:fe/service/config.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FriendMapScreen extends StatefulWidget {
  const FriendMapScreen({Key? key}) : super(key: key);

  static const String routeName = '/friendMap';

  @override
  State<FriendMapScreen> createState() => _FriendMapScreenState();
}

class _FriendMapScreenState extends State<FriendMapScreen> {
  double get latitude => getArg(context, 'latitude') is double
      ? getArg(context, 'latitude')
      : double.tryParse(getArg(context, 'latitude'))!;

  double get longitude => getArg(context, 'longitude') is double
      ? getArg(context, 'longitude')
      : double.tryParse(getArg(context, 'longitude'))!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Map'),
      ),
      body: FriendMap(
        googleApiKey: Config.gcpApiKeyWithRestriction,
        latitude: latitude,
        longitude: longitude,
        error: error,
      ),
    );
  }
}
