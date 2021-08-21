  import 'dart:async';
  import 'dart:convert';
import 'dart:math';

  import 'package:ambulance_hailer/driver/home_driver/home_driver_page.dart';
  import 'package:ambulance_hailer/library/configMaps.dart';
  import 'package:ambulance_hailer/models/rideDetails.dart';
  import 'package:ambulance_hailer/pages/authentification/login.dart';
  import 'package:ambulance_hailer/pages/home/home_page.dart';
  import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
  import "package:get/get.dart";
  import 'package:google_maps_flutter/google_maps_flutter.dart';

  class NewRidePage extends StatefulWidget {
    final RideDetails rideDetails;
    NewRidePage({this.rideDetails});

    static final CameraPosition _kGooglePlex = CameraPosition(
        target: LatLng(33.609434051916494, -7.623460799015407), zoom: 14.4746);

    @override
    _NewRidePageState createState() => _NewRidePageState();
  }

  class _NewRidePageState extends State<NewRidePage> {
    @override
    void initState() {
      super.initState();
    }

    Completer<GoogleMapController> controllerGoogleMap = Completer();
    GoogleMapController newRideGooglemapController;
    Set<Marker> markersSet =Set<Marker>();
    Set<Circle> circleSet =Set<Circle>();
    Set<Polyline> polyLineSet =Set<Polyline>();
    List<LatLng>polylineCordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    Map<PolylineId, Polyline> polylines = {};
    String placeDistance;
    double mapPaddingFromBottom = 0;
    @override
    Widget build(BuildContext context) {
      return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: Stack(
            children: [
              GoogleMap(
                //markers: Set<Marker>.of(markers),
                padding: EdgeInsets.only(bottom: mapPaddingFromBottom),
                initialCameraPosition: NewRidePage._kGooglePlex,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                polylines: polyLineSet,
                onMapCreated: (GoogleMapController controller) async{
                  setState((){
                    mapPaddingFromBottom=265.0;
                  });
                  newRideGooglemapController = controller;
                  var currentLatLong = LatLng(currentPosition.latitude,currentPosition.longitude);
                  var pickupLatLng = widget.rideDetails.pickup;
                  await calculateDistance(currentLatLong,pickupLatLng);
                },
              ),

              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0),topRight: Radius.circular(16.0)),
                    boxShadow:[
                      BoxShadow(
                        color:Colors.black38,
                        blurRadius: 16.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7,0.7),
                      ),
                    ],
                  ),
                  height: 270.0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0,vertical: 18.0),
                    child:
                    Column(
                      children: [
                        Text("10mins",style: TextStyle(fontSize: 14.0,color:Colors.deepPurple),),
                        SizedBox(height: 6.0,),
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Cephas ZOUBGA"),
                            Padding(padding: EdgeInsets.only(right: 10.0),
                              child: Icon(Icons.phone_android),
                            )
                          ],
                        ),
                        SizedBox(height: 6.0,),
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("images/car.png",height: 16.0,width:16.0),
                            Expanded(child: Container(child:   Text(
                              "Street##4,Casablanca",overflow: TextOverflow.ellipsis,
                            ),))
                          ],
                        ),
                        SizedBox(height: 6.0,),
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("images/car.png",height: 16.0,width:16.0),
                            Expanded(child: Container(child:   Text(
                              "Street##4,Casablanca",overflow: TextOverflow.ellipsis,
                            ),))
                          ],
                        ),
                        SizedBox(height: 6.0,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0,vertical: 18.0),
                          child:RaisedButton(
                            onPressed: (){},
                            color:Theme.of(context).accentColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Arrived"),Icon(Icons.directions_car)
                              ],
                            ),
                          )
                        )
                      ],
                    ),
                  )
                ),),

            ],
          ));
    }
    Future<bool> calculateDistance(LatLng pickUpLatLng,LatLng dropOffLatLng) async {
      try {
        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId("PickupId"),
          position:pickUpLatLng,
          icon: BitmapDescriptor.defaultMarker,
        );

        // Destination Location Marker
        Marker destinationMarker = Marker(
          markerId: MarkerId("DropOff"),
          position:dropOffLatLng,
          icon: BitmapDescriptor.defaultMarker,
        );
        Circle pickUpLoCircle =
        Circle(
          fillColor: Colors.blueAccent,
          center : pickUpLatLng,
          radius: 12,
          strokeWidth: 4,
          strokeColor: Colors.blueAccent,
          circleId : CircleId("dropOffId"),
        );
        Circle dropOffLoCircle =
        Circle(
          fillColor: Colors.blueAccent,
          center : dropOffLatLng,
          radius: 12,
          strokeWidth: 4,
          strokeColor: Colors.blueAccent,
          circleId : CircleId("dropOffId"),
        );
        markersSet.add(startMarker);
        markersSet.add(destinationMarker);

        double miny = (pickUpLatLng.latitude <= dropOffLatLng.latitude)
            ? pickUpLatLng.latitude
            : dropOffLatLng.latitude;
        double minx = (pickUpLatLng.longitude <= dropOffLatLng.longitude)
            ? pickUpLatLng.longitude
            : dropOffLatLng.longitude;
        double maxy = (pickUpLatLng.latitude <= dropOffLatLng.latitude)
            ? dropOffLatLng.latitude
            : pickUpLatLng.latitude;
        double maxx = (pickUpLatLng.longitude <= dropOffLatLng.longitude)
            ? dropOffLatLng.longitude
            : pickUpLatLng.longitude ;

        double southWestLatitude = miny;
        double southWestLongitude = minx;

        double northEastLatitude = maxy;
        double northEastLongitude = maxx;

        // Accommodate the two locations within the
        // camera view of the map
        newRideGooglemapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(northEastLatitude, northEastLongitude),
              southwest: LatLng(southWestLatitude, southWestLongitude),
            ),
            100.0,
          ),
        );
        await _createPolylines(pickUpLatLng.latitude, pickUpLatLng.longitude, dropOffLatLng.latitude,
            dropOffLatLng.longitude);

        double totalDistance = 0.0;

        // Calculating the total distance by adding the distance
        // between small segments
        for (int i = 0; i < polylineCordinates.length - 1; i++) {
          totalDistance += _coordinateDistance(
            polylineCordinates[i].latitude,
            polylineCordinates[i].longitude,
            polylineCordinates[i + 1].latitude,
            polylineCordinates[i + 1].longitude,
          );
        }

        setState(() {
          placeDistance = totalDistance.toStringAsFixed(2);
        });

        return true;
      } catch (e) {
        print(e);
      }
      return false;
    }
    double _coordinateDistance(lat1, lon1, lat2, lon2) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a));
    }
    // Create the polylines for showing the route between two places
    _createPolylines(double startLatitude,double startLongitude,double destinationLatitude,double destinationLongitude) async {
      polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        myApiKey,
        PointLatLng(startLatitude, startLongitude),
        PointLatLng(destinationLatitude, destinationLongitude),
        travelMode: TravelMode.transit,
      );

      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCordinates.add(LatLng(point.latitude, point.longitude));
        });
      }

      PolylineId id = PolylineId('poly');
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points:polylineCordinates,
        width: 3,
      );
      polylines[id] = polyline;
    }
  }
