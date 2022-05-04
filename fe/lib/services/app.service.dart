import 'dart:developer';

import 'package:extended/extended.dart' as ex;
import 'package:fe/services/app.router.dart';
import 'package:fe/services/click_sound.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter_svg/svg.dart';

class AppService {
  static AppService? _instance;
  static AppService get instance {
    if (_instance == null) {
      _instance = AppService();
    }
    return _instance!;
  }

  AppService() {
    ClickSoundService.instance.init();
  }

  Future pageTransitionSound() {
    return ClickSoundService.instance.play();
  }

  final router = AppRouter.instance;

  error(e, [StackTrace? stack]) {
    debugPrint('===> AppService.error();');
    debugPrint(e.toString());
    if (stack != null) {
      debugPrintStack(stackTrace: stack);
    }

    if (e.toString() == 'IMAGE_NOT_SELECTED') return;

    final ErrorInfo info = ErrorInfo.from(e);
    if (info.level == ErrorLevel.minor) {
      log('--> --> --> [ Ignore minor error & will be ignored in release ] - ${info.title}, ${info.content}');
      if (kReleaseMode) return;
    }
    ex.alert(
      TranslationService.instance.tr(info.title),
      TranslationService.instance.tr(info.content),
    );
  }

  /// Open alert box
  ///
  /// Alert box does return value.
  /// ```dart
  /// service.alert('Alert', 'This is an alert box')
  /// ```
  Future<void> alert(String title, String content) async {
    ex.alert(title, content);
  }

  Future<bool> confirm(String title, String content) async {
    return ex.confirm(title, content);
  }

  /// Send my location to the other user.
  ///
  /// 1. Ask the user for sharing location.
  /// 2. Get current location of signed in user
  /// 3. Send chat message to the user.
  /// 4. Inform the login user that location has been shared.
  Future<void> shareLocation(UserModel user) async {
    final re = await confirm(
      'FriendMap',
      'Do you want to share your location to ${user.displayName}?',
    );
    if (re == false) return;
    final pos = await LocationService.instance.currentPosition;
    await ChatService.instance.send(
      text: 'Share location',
      protocol: ChatMessageModel.createProtocol('location', "${pos.latitude},${pos.longitude}"),
      otherUid: user.uid,
    );
    alert('Location shared.', 'You have shared your location.');
  }

  /// Request other user's location.
  ///
  ///
  Future<void> requestLocation(UserModel user) async {
    await InformService.instance.inform(user.uid, {
      'type': 'requestLocation',
      'name': UserService.instance.displayName,
      'uid': UserService.instance.uid,
    });
    alert('Location request', 'Location request has been sent to ${user.displayName}!');
  }

  Future openNavigator(
      {required BuildContext context, required String title, required Coords coords}) async {
    final availableMaps = await MapLauncher.installedMaps;

    /// 설치된 지도앱이 없음
    if (availableMaps.length == 0) {
      alert('No map', 'No map app is available.');
      return;
    }

    /// 설치된 지도 앱이 하나 뿐인 경우, 그것을 사용
    if (availableMaps.length == 1) {
      try {
        await availableMaps[0].showMarker(
          coords: coords,
          title: title,
          // zoom: detail.mlevel,
        );
        return;
      } catch (e) {
        // debugPrint('====> error; $e');
      }
    }

    /// 아니면, 여러개 중 하나를 선택
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  for (var map in availableMaps)
                    ListTile(
                      onTap: () => map.showMarker(
                        coords: coords,
                        title: title,
                        // zoom: detail.mlevel,
                      ),
                      title: Text(map.mapName),
                      leading: SvgPicture.asset(
                        map.icon,
                        height: 30.0,
                        width: 30.0,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
