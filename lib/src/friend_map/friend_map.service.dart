import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MarkerIds { currentLocation, destination, empty }
enum CameraFocus { currentLocation, destination, none }

class FriendMapService {
  static FriendMapService? _instance;
  static FriendMapService get instance {
    _instance ??= FriendMapService();
    return _instance!;
  }

  /// Initializes destination location
  ///
  /// [init] can be called multiple times.
  /// [latitude] and [longitude] are being used for default markers on the map.
  Future<void> initUsersLocations({
    required double latitude,
    required double longitude,
    LocationAccuracy accuracy = LocationAccuracy.bestForNavigation,
  }) async {
    Position currentUserPosition =
        await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);

    this._currentUserLatitude = currentUserPosition.latitude;
    this._currentUserLongitude = currentUserPosition.longitude;
    this._destinationLatitude = latitude;
    this._destinationLongitude = longitude;

    return refreshMap();
  }

  /// InitialCoordinates.
  /// This will also be used as fallback values if no value is passed to the following functions:
  ///  - drawCurrentLocationMarker()
  ///  - drawDestinationLocationMarker()
  ///
  late double _currentUserLatitude;
  late double _currentUserLongitude;
  late double _destinationLatitude;
  late double _destinationLongitude;

  late GoogleMapController _mapController;

  String _currentAddress = '';
  String _otherUsersAddress = '';
  Set<Marker> _markers = {};

  double get _sLat => markers.first.position.latitude;
  double get _sLon => markers.first.position.longitude;
  double get _dLat => markers.last.position.latitude;
  double get _dLon => markers.last.position.longitude;

  /// Location Addresses
  ///
  String get currentAddress => _currentAddress;
  String get otherUsersAddress => _otherUsersAddress;

  /// Location markers.
  ///
  Set<Marker> get markers => _markers;

  set mapController(GoogleMapController controller) =>
      _mapController = controller;

  /// Camera updates will depend on this value.
  ///
  CameraFocus cameraFocus = CameraFocus.none;

  /// =========== PRIVATE FUNCTIONS =========== ///

  /// Draws marker to the map.
  /// This will remove any marker with the same MarkerId as the new one.
  ///
  bool _drawMarker(
    MarkerIds id,
    double lat,
    double lng, {
    String? title,
    String? snippet,
    BitmapDescriptor markerType = BitmapDescriptor.defaultMarker,
  }) {
    Marker? previousMarker = _getMarkerById(id);

    Marker newMarker = Marker(
      markerId: MarkerId('$id'),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(
        title: previousMarker?.infoWindow.title ?? title,
        snippet: previousMarker?.infoWindow.snippet ?? snippet,
      ),
      icon: previousMarker?.icon ?? markerType,
    );

    if (previousMarker != null) {
      /// prevents multiple marker to show on map.
      _markers.removeWhere((marker) => marker.markerId == newMarker.markerId);
    }
    _markers.add(newMarker);
    return previousMarker != null;
  }

  /// Transforms a position's coordinate to an address.
  ///
  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    String _address = '';

    try {
      List<Placemark> p = await placemarkFromCoordinates(lat, lng);

      String name =
          p[0].name != null && p[0].name!.length > 0 ? "${p[0].name!}," : '';
      String locality = p[0].locality != null && p[0].locality!.length > 0
          ? "${p[0].locality!},"
          : '';
      String country = p[0].country != null && p[0].country!.length > 0
          ? "${p[0].country!}"
          : '';

      _address = "$name $locality $country";
    } catch (e) {
      throw e;
    }
    return _address;
  }

  /// Get marker using id.
  ///
  Marker? _getMarkerById(MarkerIds id) {
    final emptyMarkerId = MarkerId(MarkerIds.empty.toString());
    final m = _markers.firstWhere(
      (m) => m.markerId == MarkerId('$id'),
      orElse: () => Marker(markerId: emptyMarkerId),
    );

    if (m.markerId == emptyMarkerId) return null;
    return m;
  }

  /// =========== PUBLIC FUNCTIONS =========== ///

  /// Returns subscribable stream of current user's location.
  ///
  Stream<Position> currentUserLocationStream({
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

  /// Update camera view.
  /// does not need to call setState() when calling this function.
  ///
  void moveCameraView(double lat, double lng, {double zoom = 18}) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: zoom),
      ),
    );
  }

  /// adjust camera view and zoom to make all markers visible on map.
  /// does not need to call setState() when calling this function.
  ///
  void adjustCameraViewAndZoom() {
    cameraFocus = CameraFocus.none;
    double miny = (_sLat <= _dLat) ? _sLat : _dLat;
    double minx = (_sLon <= _dLon) ? _sLon : _dLon;
    double maxy = (_sLat <= _dLat) ? _dLat : _sLat;
    double maxx = (_sLon <= _dLon) ? _dLon : _sLon;

    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
            northeast: LatLng(maxy, maxx), southwest: LatLng(miny, minx)),
        155.0,
      ),
    );
  }

  /// Zooms in the map view
  /// does not need to call setState() when calling this function.
  ///
  zoomIn() {
    cameraFocus = CameraFocus.none;
    _mapController.animateCamera(
      CameraUpdate.zoomIn(),
    );
  }

  /// Zooms out the map view.
  /// does not need to call setState() when calling this function.
  ///
  zoomOut() {
    cameraFocus = CameraFocus.none;
    _mapController.animateCamera(
      CameraUpdate.zoomOut(),
    );
  }

  /// Zoom to a marker position.
  /// does not need to call setState() when calling this function.
  ///
  zoomToMarker(MarkerIds id) {
    Marker? marker = _getMarkerById(id);
    if (marker == null) return;

    cameraFocus = id == MarkerIds.currentLocation
        ? CameraFocus.currentLocation
        : CameraFocus.destination;
    moveCameraView(marker.position.latitude, marker.position.longitude);
  }

  /// Marks current location.
  ///
  Future<bool> drawCurrentLocationMarker({
    double? lat,
    double? lon,
  }) async {
    /// set current address.
    _currentAddress = await _getAddressFromCoordinates(
      lat ?? _currentUserLatitude,
      lon ?? _currentUserLongitude,
    );

    return _drawMarker(
      MarkerIds.currentLocation,
      lat ?? _currentUserLatitude,
      lon ?? _currentUserLongitude,
      title: "My Location",
      markerType:
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
    );
  }

  /// Marks destination location.
  ///
  Future<void> drawDestinationLocationMarker({
    double? lat,
    double? lon,
  }) async {
    _otherUsersAddress = await _getAddressFromCoordinates(
      lat ?? _destinationLatitude,
      lon ?? _destinationLongitude,
    );

    _drawMarker(
      MarkerIds.destination,
      lat ?? _destinationLatitude,
      lon ?? _destinationLongitude,
      title: "Destination",
    );
  }

  /// refreshes the map to redraw markers and adjust camera view.
  ///
  Future<void> refreshMap() async {
    await drawDestinationLocationMarker();
    await drawCurrentLocationMarker();
    adjustCameraViewAndZoom();
  }
}
