import 'package:ambulance_hailer/library/configMaps.dart';
import 'package:ambulance_hailer/models/rideDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io' show Platform;

import '../main.dart';

class PushNotificationService{
  final FirebaseMessaging firebaseMessaging=FirebaseMessaging();

  Future initialize() async {
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        retrieveRideRequestInfo(getRideRequestId(message));
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }
  Future <String> getToken(User userDriver) async {
    String token = await firebaseMessaging.getToken();
    print("this is token : ");
    print(currentfirebaseDriver.uid);
    usersRef.child(userDriver.uid).child("token").set(token);
    firebaseMessaging.subscribeToTopic("alldrivers");
    firebaseMessaging.subscribeToTopic("allusers");
  }
  void retrieveRideRequestInfo (String rideRequestId)
  {
    newRequestRef.child(rideRequestId)
        .once()
        .then((DataSnapshot dataSnapshot){
      if (dataSnapshot.value!=null)
      {
        double pickupLocationLat = double.parse(dataSnapshot.value['pickup']['latitude'].toString());
        double pickupLocationLong = double.parse(dataSnapshot.value['pickup']['longitude'].toString());
        String pickupAddress =dataSnapshot.value['pickup_address'].toString();

        double dropLocationLat = double.parse(dataSnapshot.value['drop']['latitude'].toString());
        double dropLocationLong = double.parse(dataSnapshot.value['drop']['longitude'].toString());
        String dropAddress =dataSnapshot.value['dropoff_address'].toString();

        RideDetails rideDetails  = RideDetails(null,null, null, null, null, null, null);
        rideDetails.ride_request_id =rideRequestId;
        rideDetails.pick_address = pickupAddress;
        rideDetails.drop_address = dropAddress;
        rideDetails.pickup = LatLng(pickupLocationLat, pickupLocationLong);
        rideDetails.drop = LatLng(dropLocationLat, dropLocationLong);

        print('Information ::');
        print(rideDetails.pick_address);
        print(rideDetails.drop_address);
      }
    });
  }

  getRideRequestId(Map<String,dynamic> message)
  async {
     String rideRequestId = "";
     if (Platform.isAndroid){
        print("this is Ride Request Id ");
        rideRequestId = message["data"]["ride_request_id"];
        print(rideRequestId);
     }
     else {
       print("this is Ride Request Id ");
       rideRequestId = message["ride_request_id"];
       print(rideRequestId);
     }
     return rideRequestId;
  }
}