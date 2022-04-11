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
  final FriendMapService service = FriendMapService.instance;
  final searchBoxController = TextEditingController();

  final CameraPosition currentLocation = CameraPosition(target: LatLng(0.0, 0.0));

  StreamSubscription<Position>? currentUserPositionStream;
  StreamSubscription<DatabaseEvent>? otherUserPositionStream;

  bool reAdjustCameraView = true;

  @override
  void initState() {
    super.initState();
    init();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    otherUserPositionStream?.cancel();
    currentUserPositionStream?.cancel();
    super.dispose();
  }

  /// It will initialize both user's location.
  /// Other user's location.
  ///   - at first it will mark a temporary marker location based on the given latitude and longitude.
  ///   - then it will update the marker location with the data from firebase realtime database.
  ///
  /// By default, both user's location is shown.
  /// Current user can focus on their current location by tapping on the third icon.
  /// Current user can also show both user's locations by tapping the fourth icon, disabling focus on their current location.
  ///
  /// Zooming in and out will disable focus on current user's location.
  init() async {
    try {
      FriendMapService.instance.isCameraFocused = false;

      /// Check permission first.
      await LocationService.instance.checkPermission();

      /// Initialize users location.
      await service.initUsersLocations(
        latitude: widget.latitude,
        longitude: widget.longitude,
      );

      initPositionListeners();
      setState(() {});
    } catch (e) {
      widget.error(e);
    }
  }

  initPositionListeners() {
    /// Listen to other user's location update on realtime database.
    ///
    /// If user click on an older friend map request on chat, it will initially the coordinated on that particular chat message,
    /// and this will get the last saved location of the other user from realtime database.
    ///
    /// If current user clicked on their own friend map request and open friend map:
    ///  - other user's location will initially point to the current user's location then will update from coordinated value saved on the database.
    ///  - if the other user does not have a saved location on the database, it will simply ignore.
    otherUserPositionStream =
        userDoc(widget.otherUserUid).child('location').onValue.listen((event) async {
      // print('Other user ${widget.otherUserUid}, location update, ${event.snapshot.value}');
      DataSnapshot snapshot = event.snapshot;
      final loc = snapshot.value as String?;

      if (loc != null) {
        await service.drawDestinationLocationMarker(
          lat: double.parse(loc.split(":").first), // latitude
          lon: double.parse(loc.split(":").last), // longitude
        );

        if (reAdjustCameraView) {
          service.adjustCameraViewAndZoom();
          reAdjustCameraView = false;
        }
        if (mounted) setState(() {});
      }
    });

    currentUserPositionStream =
        service.currentUserLocationStream().listen((Position position) async {
      final updated = await service.drawCurrentLocationMarker(
        lat: position.latitude,
        lon: position.longitude,
      );

      if (updated) {
        /// Update current user location on realtime database
        userDoc(UserService.instance.uid).update(
          {'location': '${position.latitude}:${position.longitude}'},
        );

        if (service.isCameraFocused) {
          service.moveCameraView(position.latitude, position.longitude);
        }
      }

      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // print('state $state');

    service.refreshMap();
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
          zoomGesturesEnabled: false,
          myLocationButtonEnabled: false,
          initialCameraPosition: currentLocation,
          onMapCreated: (GoogleMapController controller) => service.mapController = controller,
          markers: Set<Marker>.from(service.markers),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ClipOval(
                  child: Material(
                    color: Colors.yellow.shade100, // button color
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
                    color: Colors.yellow.shade100, // button color
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
                        ? Colors.yellow.shade100
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
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ClipOval(
                  child: Material(
                    color: Colors.yellow.shade100, // button color
                    child: InkWell(
                      splashColor: Colors.blue, // inkwell color
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.zoom_out_map_rounded),
                      ),
                      onTap: () {
                        FriendMapService.instance.isCameraFocused = false;
                        service.adjustCameraViewAndZoom();
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
                          Text(
                            '* Tap the',
                            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                          SizedBox(
                            width: 24,
                            child: Icon(Icons.filter_center_focus, size: 20),
                          ),
                          Text(
                            'icon to focus/unfocus on your current position.',
                            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            '* Tap the',
                            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                          SizedBox(
                            width: 24,
                            child: Icon(Icons.zoom_out_map_rounded, size: 20),
                          ),
                          Text(
                            'to show both location.',
                            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      Divider(),
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
