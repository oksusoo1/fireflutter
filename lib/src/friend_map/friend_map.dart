import 'dart:async';

import 'package:fireflutter/src/defines.dart';
import 'package:fireflutter/src/friend_map/friend_map.service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FriendMap extends StatefulWidget {
  const FriendMap({required this.googleApiKey, required this.error, Key? key}) : super(key: key);

  final String googleApiKey;
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

    service.init(googleApiKey: widget.googleApiKey);

    getCurrentLocation();

    /// TODO save to firebase database so other user can subscribe for live location update.
    /// TODO Do not update the same location.
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

  /// Search for other location using address.
  searchOtherLocation(String address) async {
    if (address.isEmpty) return;
    try {
      List<Location> locations = await locationFromAddress(address);
      service.addMarker(
        MarkerIds.destination,
        locations[0].latitude,
        locations[0].longitude,
        title: "Destination",
        snippet: address,
        removeMarkerWithId: MarkerIds.destination,
      );
      service.adjustCameraViewAndZoom();
      if (mounted) setState(() {});
    } catch (e) {
      // print(e.toString());
      widget.error('Cannot find location for the specified address');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
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
            child: Column(
              children: [
                if (service.canGetDirections)
                  TextButton(
                    onPressed: () async {
                      try {
                        await service.addPolylines();
                        setState(() {});
                      } catch (e) {
                        widget.error(e);
                      }
                    },
                    child: Text('Get Directions'),
                  ),
                Text('My location: ' + service.currentAddress),
                TextFormField(
                  controller: searchBoxController,
                  onFieldSubmitted: (key) => searchOtherLocation(key),
                  decoration: InputDecoration(hintText: 'Search'),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
