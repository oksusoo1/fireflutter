import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

import '../../fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FriendMap extends StatefulWidget {
  const FriendMap({
    required this.googleApiKey,
    required this.otherUserUid,
    required this.latitude,
    required this.longitude,
    required this.error,
    Key? key,
  }) : super(key: key);

  final String googleApiKey;
  final String otherUserUid;
  final double latitude;
  final double longitude;
  final ErrorCallback error;

  @override
  _FriendMapState createState() => _FriendMapState();
}

class _FriendMapState extends State<FriendMap> with WidgetsBindingObserver, DatabaseMixin {
  FriendMapService service = FriendMapService.instance;
  final searchBoxController = TextEditingController();

  CameraPosition currentLocation = CameraPosition(target: LatLng(0.0, 0.0));

  StreamSubscription<Position>? currentUserPositionStream;
  StreamSubscription<DatabaseEvent>? otherUserPositionStream;

  @override
  void initState() {
    super.initState();

    service.init(
      latitude: widget.latitude.toDouble(),
      longitude: widget.longitude.toDouble(),
    );

    markUsersLocations();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    otherUserPositionStream?.cancel();
    currentUserPositionStream?.cancel();
    super.dispose();
  }

  /// Marks users locations.
  ///
  markUsersLocations() async {
    try {
      await service.markUsersLocations();
      // await service.drawPolylines();
      initPositionListener();
    } catch (e) {
      widget.error(e);
    }
    if (mounted) setState(() {});
  }

  initPositionListener() {
    /// Listen to other user's location update on realtime database.
    ///
    /// If user click on an older friend map request on chat, it will initially the coordinated on that particular chat message,
    /// and this will get the last saved location of the other user from realtime database.
    otherUserPositionStream =
        userDoc(widget.otherUserUid).child('location').onValue.listen((event) {
      print('Other user location update, $event');
      DataSnapshot snapshot = event.snapshot;
      final loc = snapshot.value as String?;

      if (loc != null) {
        service.updateMarkerPosition(
          MarkerIds.destination,
          double.parse(loc.split(":").first), // latitude
          double.parse(loc.split(":").last), // longitude
        );
        if (mounted) setState(() {});
      }
    });

    currentUserPositionStream = service.initLocationListener().listen((Position position) async {
      // print('position changed: lat ${position.latitude} ; lng ${position.longitude}');

      final updated = await service.updateMarkerPosition(
        MarkerIds.currentLocation,
        position.latitude,
        position.longitude,
      );

      if (updated) {
        /// Update current user location on realtime database
        userDoc(UserService.instance.uid).update(
          {'location': '${position.latitude}:${position.longitude}'},
        );

        if (service.isCameraFocused) service.moveCameraView(position.latitude, position.longitude);
      }

      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // print('state $state');

    if (state == AppLifecycleState.resumed && !LocationService.instance.locationServiceEnabled) {
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
                ),
                SizedBox(height: 20),

                /// Button to enable/disable camera adjustment when moving.
                ClipOval(
                  child: Material(
                    color: FriendMapService.instance.isCameraFocused
                        ? Colors.green.shade200
                        : Colors.grey.shade400, // button color
                    child: InkWell(
                      splashColor: Colors.blue, // inkwell color
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.filter_center_focus),
                      ),
                      onTap: () {
                        if (!FriendMapService.instance.isCameraFocused) {
                          service.zoomToMe();
                        }
                        FriendMapService.instance.isCameraFocused =
                            !FriendMapService.instance.isCameraFocused;
                      },
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
            child: LocationService.instance.locationServiceEnabled
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
