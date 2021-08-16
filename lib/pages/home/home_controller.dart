import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:getx_app/library/place_request.dart';
import 'package:getx_app/models/directions_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

class HomeController extends GetxController {
  TextEditingController startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();
  final startAddressFocusNode = FocusNode();
  final destinationAddressFocusNode = FocusNode();
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  Set<Marker> markers = new Set();
  LatLng initialPosition = LatLng(33.609434051916494, -7.623460799015407);
  CameraPosition initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;
  BitmapDescriptor bitmapDescriptor;
  String placeDistancex;
  String startAddress = '';
  String destinationAddress = '';
  String currentAddress = '';
  Position currentPosition;
  PolylinePoints polylinePoints;
  DatabaseReference rideRequestRef;
  @override
  void dispose() {
    super.dispose();
  }
  @override
  onInit() async {
    super.onInit();
  }

  void cancelRideRequest(){
    rideRequestRef.remove();
  }

}