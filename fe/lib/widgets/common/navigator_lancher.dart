import 'package:fe/services/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:map_launcher/map_launcher.dart';

class NavigatorLauncher extends StatelessWidget {
  NavigatorLauncher(
      {Key? key, required this.child, required this.markerTitle, required this.coords})
      : super(key: key);

  final Widget child;
  final String markerTitle;
  final Coords coords;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        try {
          final availableMaps = await MapLauncher.installedMaps;

          /// 설치된 지도앱이 없음
          if (availableMaps.length == 0) {
            service.alert('No map', 'No map app is available.');
            return;
          }

          /// 설치된 지도 앱이 하나 뿐인 경우, 그것을 사용
          if (availableMaps.length == 1) {
            try {
              await availableMaps[0].showMarker(
                coords: coords,
                title: markerTitle,
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
                              title: markerTitle,
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
        } catch (e) {
          service.error(e);
        }
      },
    );
  }
}
