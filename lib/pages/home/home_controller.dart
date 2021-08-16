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