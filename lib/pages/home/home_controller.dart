import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:getx_app/library/place_request.dart';
import 'package:getx_app/models/directions_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

class HomeController extends GetxController {

  final actualPositionController  = TextEditingController();
  final destinationPositionController = TextEditingController().obs;
  Rx<LatLng> initialPosition=LatLng(33.609434051916494, -7.623460799015407).obs;
  bool locationServiceActive = true;
  Completer<GoogleMapController> _controller = Completer();
  Set<Polyline> _polyLines = {};
  Set<Polyline> get polyLines => _polyLines;
  Set<Marker> _markers = {};
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  GoogleMapController googleMapController;
  Marker origin;
  Marker destination;
  Directions info;

  @override
  void dispose() {
    googleMapController.dispose();
    super.dispose();
  }
  @override
  onInit() async {
    super.onInit();
    _getUserLocation();
    _loadingInitialPosition();
  }

  void onMapCreated(GoogleMapController mapController) {
    mapController = mapController;
    //mapController.setMapStyle(Utils.mapStyles);
   // _controller.complete(mapController);
   // setMapPins();
   // setPolylines();
  }
  void createRoute(String decodeRoute) {
    print(decodeRoute);
    _polyLines = {};
    var uuid = new Uuid();
    String polyId = uuid.v1();
    _polyLines.add(Polyline(
        polylineId: PolylineId(polyId),
        width: 8,
        color: Colors.black,
        onTap: () {},
        points: _convertToLatLng(_decodePoly(decodeRoute))));
    print(_polyLines);
  }
  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }
  void sendRequest(String intendedLocation) async {
    List<Location> Placemark = await locationFromAddress(intendedLocation);
    double latitude = Placemark[0].latitude;
    double longitude = Placemark[0].longitude;
    LatLng destination = LatLng(latitude, longitude);
   // _addMarker(destination, intendedLocation);
    String route = await _googleMapsServices.getRouteCoordinates(
        initialPosition.value, destination);
    createRoute(route);
    print(route);
  }
  void _addMarker(LatLng location, String address) {
   /* _markers.add(Marker(
        markerId: MarkerId(_lastPosition.toString()),
        position: location,
        infoWindow: InfoWindow(title: address, snippet: "go here"),
        icon: BitmapDescriptor.defaultMarker));*/
  }
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
// repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

/*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }
/*  void setMapPins() {

      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position:_initialPosition,
          icon: sourceIcon));
      // destination pin
      _markers.add(Marker(
          markerId: MarkerId('destPin'),
          position: DEST_LOCATION,
          icon: destinationIcon));
  }
  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');
  }*/
  void _getUserLocation() async {
    print("GET USER METHOD RUNNING =========");
   Position position = await Geolocator.getCurrentPosition();
   print(position.latitude);
    initialPosition.value = LatLng(position.latitude, position.longitude);
    List<Placemark> placemark = await placemarkFromCoordinates(
        position.latitude,
        position.longitude
    );
    actualPositionController.text = placemark[0].street;
    print("initial position is : ${initialPosition.toString()}");
    update();
  }

  void _loadingInitialPosition()async{
    await Future.delayed(Duration(seconds: 5)).then((v) {
      if(initialPosition.value  == null){
        locationServiceActive = false;
      }
    });
  }
}

class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}