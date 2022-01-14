import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MarkerIds {
  static String currentLocation = 'currentLocation';
  static String destination = 'destination';
}

class MapsErrors {
  static String locationServiceDisabled = 'Location services are disabled.';
  static String locationPermissionDenied = 'Location permissions are denied';
  static String locationPermissionPermanentlyDenied =
      'Location permissions are permanently denied, we cannot request permissions.';
}

class FriendMapService {
  static FriendMapService? _instance;
  static FriendMapService get instance {
    _instance ??= FriendMapService();
    return _instance!;
  }

  init({required String googleApiKey}) {
    _apiKey = googleApiKey;
  }

  String _apiKey = '';

  String _currentAddress = '';
  String get currentAddress => _currentAddress;

  /// Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> _polylines = {};
  get polylines => _polylines;

  /// Location markers.
  ///
  Set<Marker> _markers = {};
  get markers => _markers;

  double get _startLatitude => markers.first.position.latitude;
  double get _destinationLatitude => markers.last.position.latitude;
  double get _startLongitude => markers.first.position.longitude;
  double get _destinationLongitude => markers.last.position.longitude;

  late GoogleMapController _mapController;
  set mapController(controller) => _mapController = controller;

  ///
  bool get canGetDirections => markers.length > 1;

  /// Initialize location change listener
  ///
  ///
  Stream<Position> initLocationListener({
    int distanceFilter = 0,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        distanceFilter: distanceFilter,
        accuracy: accuracy,
      ),
    );
  }

  /// Checks necessary permission for geolocator.
  /// Throws error if permission is not granted.
  ///
  Future<dynamic> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw MapsErrors.locationServiceDisabled;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw MapsErrors.locationPermissionDenied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw MapsErrors.locationPermissionPermanentlyDenied;
    }

    return true;
  }

  /// Gets the current position of the user.
  ///
  Future getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    await checkPermission();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);

    /// set current address.
    _currentAddress = await getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    /// Mark current location.
    addMarker(
      MarkerIds.currentLocation,
      position.latitude,
      position.longitude,
      title: "My Location",
      snippet: _currentAddress,
      markerType: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    );

    /// update map view.
    moveCameraView(position.latitude, position.longitude);
  }

  /// Transforms a position's coordinate to an address.
  ///
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    String _address = '';

    try {
      List<Placemark> p = await placemarkFromCoordinates(lat, lng);
      _address = "${p[0].name}, ${p[0].locality}, ${p[0].postalCode}, ${p[0].country}";
    } catch (e) {
      throw e;
    }
    return _address;
  }

  /// add marker to map.
  ///
  void addMarker(
    String id,
    double lat,
    double lng, {
    String? title,
    String? snippet,
    BitmapDescriptor markerType = BitmapDescriptor.defaultMarker,
    String? removeMarkerWithId,
  }) {
    Marker marker = Marker(
      markerId: MarkerId('$id'),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title, snippet: snippet),
      icon: markerType,
    );

    if (removeMarkerWithId != null) {
      _markers.removeWhere((m) => m.markerId.value == removeMarkerWithId);
    }

    if (_polylines.length > 0) _polylines.clear();

    _markers.add(marker);
  }

  /// Updates the existing marker on the map.
  ///
  updateMarkerPosition(String id, double lat, double lng,
      {bool adjustCameraView = false, double cameraZoom = 18}) {
    Marker previousMarker = _markers.firstWhere((m) => m.markerId.value == id);
    Marker marker = Marker(
      markerId: MarkerId(id),
      position: LatLng(lat, lng),
      infoWindow: previousMarker.infoWindow,
      icon: previousMarker.icon,
    );
    _markers.removeWhere((m) => m.markerId.value == id);
    _markers.add(marker);
    if (adjustCameraView) moveCameraView(lat, lng, zoom: cameraZoom);
  }

  /// Adding Polylines
  ///
  Future<void> addPolylines({TravelMode travelMode = TravelMode.driving}) async {
    // Initializing PolylinePoints
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      _apiKey,
      PointLatLng(_startLatitude, _startLongitude),
      PointLatLng(_destinationLatitude, _destinationLongitude),
      travelMode: travelMode,
    );

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    _polylines[id] = polyline;
  }

  /// Update camera view.
  ///
  /// does not need to call "setState()" after calling this function.
  ///
  void moveCameraView(double lat, double lng, {double zoom = 18}) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, lng), zoom: zoom)),
    );
  }

  /// adjust camera view and zoom to make all markers visible on map.
  ///
  /// does not need to call "setState()" after calling this function.
  ///
  void adjustCameraViewAndZoom() {
    double miny = (_startLatitude <= _destinationLatitude) ? _startLatitude : _destinationLatitude;
    double minx =
        (_startLongitude <= _destinationLongitude) ? _startLongitude : _destinationLongitude;
    double maxy = (_startLatitude <= _destinationLatitude) ? _destinationLatitude : _startLatitude;
    double maxx =
        (_startLongitude <= _destinationLongitude) ? _destinationLongitude : _startLongitude;

    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(northeast: LatLng(maxy, maxx), southwest: LatLng(miny, minx)),
        100.0,
      ),
    );
  }
}
