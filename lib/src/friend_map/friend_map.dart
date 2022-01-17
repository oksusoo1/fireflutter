import 'dart:async';

import 'package:fireflutter/src/defines.dart';
import 'package:fireflutter/src/friend_map/friend_map.service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FriendMap extends StatefulWidget {
  const FriendMap({
    required this.googleApiKey,
    required this.otherUid,
    required this.error,
    Key? key,
  }) : super(key: key);

  final String googleApiKey;
  final String otherUid;
  final ErrorCallback error;

  @override
  _FriendMapState createState() => _FriendMapState();
}

class _FriendMapState extends State<FriendMap> {
  FriendMapService service = FriendMapService.instance;
  final searchBoxController = TextEditingController();

  CameraPosition currentLocation = CameraPosition(target: LatLng(0.0, 0.0));

  late StreamSubscription<Position> positionStream;

  @override
  void initState() {
    super.initState();

    service.init(googleApiKey: widget.googleApiKey, otherUid: widget.otherUid);

    getCurrentLocation();

    positionStream = service.initLocationListener().listen((Position position) {
      print('position changed: lat ${position.latitude} ; lng ${position.longitude}');

      service.updateMarkerPosition(
        MarkerIds.currentLocation,
        position.latitude,
        position.longitude,
        adjustCameraView: true,
      );
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  /// Get current position of the user.
  getCurrentLocation() async {
    try {
      await service.getCurrentPosition();
      if (mounted) setState(() {});
    } catch (e) {
      print(e.toString());
      widget.error('Error getting your location.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          mapToolbarEnabled: false,
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          initialCameraPosition: currentLocation,
          onMapCreated: (GoogleMapController controller) => service.mapController = controller,
          markers: Set<Marker>.from(service.markers),
          polylines: Set<Polyline>.of(service.polylines.values),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.blueAccent),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'My location: ' + service.currentAddress,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
