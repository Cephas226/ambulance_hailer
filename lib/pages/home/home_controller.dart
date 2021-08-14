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
  Set<Marker> markers = {};
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  GoogleMapController googleMapController;
  Marker origin;
  Marker destination;
  Directions info;

  // ---
  BitmapDescriptor carPin;

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
    update();
  }
  Set<Marker> getmarkers() { //markers to place on map
    markers.add(Marker( //add first marker
      markerId: MarkerId(initialPosition.value.toString()),
      position: initialPosition.value, //position of marker
      infoWindow: InfoWindow( //popup info
        title: 'Marker Title First ',
        snippet: 'My Custom Subtitle',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));

    markers.add(Marker( //add second marker
      markerId: MarkerId(initialPosition.value.toString()),
      position: LatLng(27.7099116, 85.3132343), //position of marker
      infoWindow: InfoWindow( //popup info
        title: 'Marker Title Second ',
        snippet: 'My Custom Subtitle',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));

    markers.add(Marker( //add third marker
      markerId: MarkerId(initialPosition.value.toString()),
      position: LatLng(27.7137735, 85.315626), //position of marker
      infoWindow: InfoWindow( //popup info
        title: 'Marker Title Third ',
        snippet: 'My Custom Subtitle',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));
    return markers;
  }

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