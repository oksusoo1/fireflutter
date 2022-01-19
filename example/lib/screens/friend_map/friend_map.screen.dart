import 'package:extended/extended.dart';
import 'package:fe/services/config.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendMapScreen extends StatelessWidget {
  const FriendMapScreen({Key? key}) : super(key: key);

  double get latitude => Get.arguments['latitude'] is double
      ? Get.arguments['latitude']
      : double.tryParse(Get.arguments['latitude'])!;
  double get longitude => Get.arguments['longitude'] is double
      ? Get.arguments['longitude']
      : double.tryParse(Get.arguments['longitude'])!;

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
