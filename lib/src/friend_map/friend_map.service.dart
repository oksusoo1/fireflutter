import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MarkerIds {
  static String currentLocation = 'currentLocation';
  static String destination = 'destination';
}

/// TODO - move this code to location service.

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

  /// Initialize
  ///
  /// [init] can be called multiple times.
  /// [latitude] and [longitude] are being used for default markers on the map.
  init({
    required String googleApiKey,
    double latitude = 0,
    double longitude = 0,
  }) {
    _apiKey = googleApiKey;
    this.latitude = latitude;
    this.longitude = longitude;
  }

  /// TODO - move this code to location service.
  /// [_locationServiceEnabled] is set to true when the user consent on location service and the app has location service.
  bool _locationServiceEnabled = false;

  /// Use [locationServiceEnabled] to check if the app has location service permission.
  bool get locationServiceEnabled => _locationServiceEnabled;

  String _apiKey = '';
  late double latitude;
  late double longitude;

  String _currentAddress = '';
  String get currentAddress => _currentAddress;
  String _otherUsersAddress = '';
  String get otherUsersAddress => _otherUsersAddress;

  /// Map storing polylines created by connecting two points.
  ///
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
  set mapController(GoogleMapController controller) => _mapController = controller;

  /// Initialize location change listener
  ///
  Stream<Position> initLocationListener({
    int distanceFilter = 0,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(distanceFilter: distanceFilter, accuracy: accuracy),
    );
  }

  /// Checks necessary permission for geolocator.
  /// Throws error if permission is not granted.
  ///
  /// TODO - move this code to location service.
  Future<dynamic> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    /// The location service is available on the phone?
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    /// If not, then alert user that location service is turned off.
    if (!serviceEnabled) {
      _locationServiceEnabled = false;
      throw MapsErrors.locationServiceDisabled;
    }

    /// When location service is turned on, request permission.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _locationServiceEnabled = false;
        throw MapsErrors.locationPermissionDenied;
      }
    }

    ///
    if (permission == LocationPermission.deniedForever) {
      _locationServiceEnabled = false;
      throw MapsErrors.locationPermissionPermanentlyDenied;
    }

    _locationServiceEnabled = true;
    return _locationServiceEnabled;
  }

  /// Return current positoin.
  ///
  /// TODO - move this code to location service.
  Future<Position> get currentPosition async {
    await checkPermission();
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  /// Marks locations on screen.
  ///
  Future markUsersLocations({
    LocationAccuracy accuracy = LocationAccuracy.bestForNavigation,
  }) async {
    await checkPermission();

    Position currentUserPosition = await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);

    /// set current address.
    _currentAddress = await getAddressFromCoordinates(
      currentUserPosition.latitude,
      currentUserPosition.longitude,
    );

    addMarker(
      MarkerIds.currentLocation,
      currentUserPosition.latitude,
      currentUserPosition.longitude,
      title: "My Location",
      snippet: _currentAddress,
      markerType: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
    );

    _otherUsersAddress = await getAddressFromCoordinates(
      latitude,
      longitude,
    );

    addMarker(
      MarkerIds.destination,
      latitude,
      longitude,
      title: "Destination",
      snippet: _otherUsersAddress,
    );

    adjustCameraViewAndZoom();
  }

  /// Transforms a position's coordinate to an address.
  ///
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    String _address = '';

    try {
      List<Placemark> p = await placemarkFromCoordinates(lat, lng);
      _address = "${p[0].name}, ${p[0].locality}, ${p[0].country}";
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
  }) {
    Marker marker = Marker(
      markerId: MarkerId('$id'),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title, snippet: snippet),
      icon: markerType,
    );

    /// resets the polylines.
    if (_polylines.length > 0) _polylines.clear();

    /// prevents multiple marker to show on map.
    _markers.removeWhere((m) => m.markerId.value == id);

    _markers.add(marker);
  }

  /// Updates the existing marker on the map.
  ///
  updateMarkerPosition(
    String id,
    double lat,
    double lng, {
    bool adjustCameraView = false,
    double cameraZoom = 18,
  }) {
    if (_markers.isEmpty) return;
    Marker previousMarker = _markers.firstWhere((m) => m.markerId.value == id);
    if (previousMarker.position.latitude == lat && previousMarker.position.longitude == lng) {
      /// Do nothing, it's the same coordinates..
    } else {
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
  }

  /// Adding Polylines
  ///
  /// NOTE
  ///  - `Directions API` mus be enabled on Google Cloud Platform.
  ///  - `Directions Api` must also be included in the API restriction of the Api Key in used.
  ///  - Billing must be enabled on the Google Cloud Project.
  ///
  Future<void> addPolylines({
    TravelMode travelMode = TravelMode.driving,
  }) async {
    // Initializing PolylinePoints
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      _apiKey,
      PointLatLng(_startLatitude, _startLongitude),
      PointLatLng(_destinationLatitude, _destinationLongitude),
      travelMode: travelMode,
    );

    if (result.status == 'REQUEST_DENIED') {
      /// throw '${result.status} - ${result.errorMessage}';
      print('${result.status} - ${result.errorMessage}');
    }

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
        150.0,
      ),
    );
  }

  zoomIn() {
    _mapController.animateCamera(
      CameraUpdate.zoomIn(),
    );
  }

  zoomOut() {
    _mapController.animateCamera(
      CameraUpdate.zoomOut(),
    );
  }
}
