import 'dart:async';

import '../../fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FriendMap extends StatefulWidget {
  const FriendMap({
    required this.googleApiKey,
    required this.latitude,
    required this.longitude,
    required this.error,
    Key? key,
  }) : super(key: key);

  final String googleApiKey;
  final double latitude;
  final double longitude;
  final ErrorCallback error;

  @override
  _FriendMapState createState() => _FriendMapState();
}

class _FriendMapState extends State<FriendMap> with WidgetsBindingObserver {
  FriendMapService service = FriendMapService.instance;
  final searchBoxController = TextEditingController();

  CameraPosition currentLocation = CameraPosition(target: LatLng(0.0, 0.0));

  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();

    service.init(
      googleApiKey: widget.googleApiKey,
      latitude: widget.latitude.toDouble(),
      longitude: widget.longitude.toDouble(),
    );

    markUsersLocations();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    positionStream?.cancel();
    super.dispose();
  }

  /// Marks users locations.
  ///
  markUsersLocations() async {
    try {
      await service.markUsersLocations();
      await service.addPolylines();
      initPositionListener();
    } catch (e) {
      widget.error(e);
    }
    if (mounted) setState(() {});
  }

  initPositionListener() {
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // print('state $state');

    if (state == AppLifecycleState.resumed && !service.locationServiceEnabled) {
      markUsersLocations();
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
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ClipOval(
                  child: Material(
                    color: Colors.blue.shade100, // button color
                    child: InkWell(
                      splashColor: Colors.blue, // inkwell color
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.add),
                      ),
                      onTap: () => service.zoomIn(),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ClipOval(
                  child: Material(
                    color: Colors.blue.shade100, // button color
                    child: InkWell(
                      splashColor: Colors.blue, // inkwell color
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.remove),
                      ),
                      onTap: () => service.zoomOut(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: service.locationServiceEnabled
                ? Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.cyanAccent),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'My location: ' + service.currentAddress,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Destination: ' + service.otherUsersAddress,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Geolocator.openLocationSettings(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Turn on location service to continue using map.'),
                        Icon(Icons.settings),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
