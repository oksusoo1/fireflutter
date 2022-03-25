import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../location/location.service.dart';

enum MarkerIds { currentLocation, destination }

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
    // required String googleApiKey,
    double latitude = 0,
    double longitude = 0,
  }) {
    // _apiKey = googleApiKey;
    this.latitude = latitude;
    this.longitude = longitude;
  }

  // Other user's/destination initial coordinate
  double latitude = 0;
  double longitude = 0;

  String _currentAddress = '';
  String get currentAddress => _currentAddress;
  String _otherUsersAddress = '';
  String get otherUsersAddress => _otherUsersAddress;

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

  /// If this is enabled, the camera view will follow and focus on the user's location on every changes.
  ///
  bool isCameraFocused = false;
  double defaultCameraZoom = 18;

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

  /// Marks locations on screen.
  ///
  Future markUsersLocations({
    LocationAccuracy accuracy = LocationAccuracy.bestForNavigation,
  }) async {
    print('Mark users locations');
    await LocationService.instance.checkPermission();

    Position currentUserPosition = await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);

    /// set current address.
    // _currentAddress = await getAddressFromCoordinates(
    //   currentUserPosition.latitude,
    //   currentUserPosition.longitude,
    // );

    drawMarker(
      MarkerIds.currentLocation,
      currentUserPosition.latitude,
      currentUserPosition.longitude,
      title: "My Location",
      snippet: _currentAddress,
      markerType: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
    );

    // _otherUsersAddress = await getAddressFromCoordinates(
    //   latitude,
    //   longitude,
    // );

    drawMarker(
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

  void drawCurrentUserMarker(double lat, double lon) {
    return drawMarker(
      MarkerIds.currentLocation,
      lat,
      lon,
      title: "My Location",
      snippet: _otherUsersAddress,
    );
  }

  void drawOtherUserMarker(double lat, double lon) {
    return drawMarker(
      MarkerIds.destination,
      lat,
      lon,
      title: "Destination",
      snippet: _otherUsersAddress,
    );
  }

  /// draw marker to map.
  ///
  void drawMarker(
    MarkerIds id,
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
    // if (_polylines.length > 0) _polylines.clear();

    /// prevents multiple marker to show on map.
    _markers.removeWhere((m) => m.markerId.value == id.toString());

    _markers.add(marker);
  }

  /// Updates the existing marker on the map.
  ///
  /// returns true if marker location is updated.
  bool updateMarkerPosition(
    MarkerIds id,
    double lat,
    double lng, {
    double cameraZoom = 18,
  }) {
    if (_markers.isEmpty) return false;
    Marker previousMarker = _markers.firstWhere((m) => m.markerId.value == id.toString());
    if (previousMarker.position.latitude == lat && previousMarker.position.longitude == lng) {
      /// Do nothing, it's the same coordinates..
      return false;
    } else {
      Marker marker = Marker(
        markerId: MarkerId(id.toString()),
        position: LatLng(lat, lng),
        infoWindow: previousMarker.infoWindow,
        icon: previousMarker.icon,
      );
      _markers.removeWhere((m) => m.markerId.value == id.toString());
      _markers.add(marker);

      /// NOTE: when either of the other or current user's position changed, this will re draw the lines on the map.
      // await drawPolylines();

      return true;
    }
  }

  /// Update camera view.
  ///
  /// does not need to call "setState()" after calling this function.
  ///
  void moveCameraView(double lat, double lng, {double zoom = 18}) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: zoom),
      ),
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

  zoomToMe() {
    Marker myMarker = _markers.firstWhere(
      (m) => m.markerId.value == MarkerIds.currentLocation.toString(),
    );
    moveCameraView(myMarker.position.latitude, myMarker.position.longitude);
  }
}
