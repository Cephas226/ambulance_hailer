import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:ambulance_hailer/main.dart';
import 'package:ambulance_hailer/pages/home/home_controller.dart';
import 'package:ambulance_hailer/utils/CustomTextStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:get/get.dart';
import 'package:ambulance_hailer/assistant/assistantMethods.dart';
import 'package:ambulance_hailer/library/configMaps.dart';
import 'package:ambulance_hailer/library/place_request.dart';
import 'package:ambulance_hailer/pages/DataHandler/appData.dart';
import 'package:ambulance_hailer/pages/components/menu.dart';
import 'package:ambulance_hailer/pages/components/menu1.dart';
import 'package:ambulance_hailer/pages/trip/request_driver_trip.dart';
import 'package:ambulance_hailer/pages/trip/payment_dialog.dart';
import 'package:ambulance_hailer/utils/bottom_sheet.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'home_driver_controller.dart';
import 'package:provider/provider.dart';

class HomeDriverPage extends StatefulWidget {
  @override
  _HomeDriverPageState createState() => _HomeDriverPageState();
}

class _HomeDriverPageState extends State<HomeDriverPage> {
  Set<Marker> markers = new Set();
  HomeController hController = Get.put(HomeController());
  String _placeDistance;
  CameraPosition initialLocation = CameraPosition(target: LatLng(33.609434051916494, -7.623460799015407),zoom: 14.4746);
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  LatLng initialPosition = LatLng(33.609434051916494, -7.623460799015407);
  GoogleMapController mapController;
  BitmapDescriptor bitmapDescriptor;
  String placeDistancex;
  String startAddress = '';
  String destinationAddress = '';
  RxString currentAddress = ''.obs;
  Position currentPosition;
  PolylinePoints polylinePoints;
  TextEditingController startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();
  final startAddressFocusNode = FocusNode();
  final destinationAddressFocusNode = FocusNode();
  final firestore = FirebaseFirestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  BehaviorSubject<double> radius = BehaviorSubject.seeded(100.0);
  Stream<dynamic> query;

  // Subscription
  StreamSubscription subscription;
  Color driverStatusColor=Colors.black;
  String driversStatusText='Offline Now - Go online';
  bool isDriverAvailable=false;
  //----
  Completer <GoogleMapController> _controllerGroupMap = Completer();
  GoogleMapController newGoogleMapController;
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    GoogleMapsServices.getCurrentOnLineUserInfo();
    String pathToReference = "availableDriver";
    Geofire.initialize(pathToReference);
  }

  void saveRideRequest() async {
    hController.rideRequestRef =
        FirebaseDatabase.instance.reference().child("Ride Requests").push();
    // Retrieving placemarks from addresses
    List<Location> startPlacemark = await locationFromAddress(startAddress);
    List<Location> destinationPlacemark = await locationFromAddress(destinationAddress);

    // Use the retrieved coordinates of the current position,
    // instead of the address if the start position is user's
    // current position, as it results in better accuracy.
    double startLatitude = startAddress == currentAddress
        ? currentPosition.latitude
        : startPlacemark[0].latitude;

    double startLongitude = startAddress == currentAddress
        ? currentPosition.longitude
        : startPlacemark[0].longitude;

    double destinationLatitude = destinationPlacemark[0].latitude;
    double destinationLongitude = destinationPlacemark[0].longitude;

    String startCoordinatesString = '($startLatitude, $startLongitude)';
    String destinationCoordinatesString =
        '($destinationLatitude, $destinationLongitude)';

   // print(pickUp);


    Map pickUpLocMap = {
      "latitude": startLatitude,
      "longitude": startLongitude,
    };
    Map dropOffMap = {
      "latitude": destinationLatitude,
      "longitude": destinationLongitude,
    };
    Map rideInfoMap = {
      "driver_in": "waiting",
      "payment_method":"cash",
      "pickup":pickUpLocMap,
      "drop":dropOffMap,
      "created_at":DateTime.now().toString(),
      "rider_name":"Cephas",
      "rider_phone":"0639607953",
      "pickup_address":startAddress,
      "dropoff_address":destinationAddressController.text
    };
    hController.rideRequestRef.push().set(rideInfoMap);
  }


  Future<bool> _calculateDistance() async {
    try {
      // Retrieving placemarks from addresses
      List<Location> startPlacemark = await locationFromAddress(startAddress);
      List<Location> destinationPlacemark = await locationFromAddress(destinationAddress);

      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      double startLatitude = startAddress == currentAddress
          ?currentPosition.latitude
          : startPlacemark[0].latitude;

      double startLongitude = startAddress == currentAddress
          ? currentPosition.longitude
          : startPlacemark[0].longitude;

      double destinationLatitude = destinationPlacemark[0].latitude;
      double destinationLongitude = destinationPlacemark[0].longitude;

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString ='($destinationLatitude, $destinationLongitude)';
      print(destinationAddress.toString());
      // Start Location Marker
      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinatesString),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(
          title: 'Start $startCoordinatesString',
          snippet:startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCoordinatesString',
          snippet:destinationAddressController.text,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Adding the markers to the list
      markers.add(startMarker);
      markers.add(destinationMarker);

      markers.add(Marker(
          //add first marker
          markerId: MarkerId(initialPosition.toString() + 1.0.toString()),
          position: LatLng(33.609434051916494, -7.623460799015407),
          infoWindow: InfoWindow(
            //popup info
            title: 'Marker Title First ',
            snippet: 'My Custom Subtitle',
          ),
          icon: await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(devicePixelRatio: 1.5),
              'images/taxi.png') //Icon for Marker
          ));

      markers.add(Marker(
        //add second marker
        markerId: MarkerId(initialPosition.toString() + 2.0.toString()),
        position: LatLng(33.589939805473726, -7.591033264638604),
        infoWindow: InfoWindow(
          //popup info
          title: 'Marker Title Second ',
          snippet: 'My Custom Subtitle',
        ),
        icon: await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 1.5),
            'images/taxi.png'), //Icon for Marker
      ));

      markers.add(Marker(
        //add second marker
        markerId: MarkerId(initialPosition.toString() + 3.0.toString()),
        position: LatLng(33.599924400228765, -7.612786721808061),
        infoWindow: InfoWindow(
          //popup info
          title: 'Marker Title Second ',
          snippet: 'My Custom Subtitle',
        ),
        icon: await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5),
            'images/taxi.png'), //Icon for Marker
      ));
      markers.add(Marker(
        //add second marker
        markerId: MarkerId(initialPosition.toString() + 4.0.toString()),
        position: LatLng(33.58414632897516, -7.623243031941734),
        infoWindow: InfoWindow(
          //popup info
          title: 'Marker Title Second ',
          snippet: 'My Custom Subtitle',
        ),
        icon: await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5),
            'images/taxi.png'), //Icon for Marker
      ));

      // Calculating to check that the position relative
      // to the frame, and pan & zoom the camera accordingly.
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      // Accommodate the two locations within the
      // camera view of the map
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );

      // Calculating the distance between the start and the end positions
      // with a straight path, without considering any route
      // double distanceInMeters = await Geolocator.bearingBetween(
      //   startLatitude,
      //   startLongitude,
      //   destinationLatitude,
      //   destinationLongitude,
      // );

      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);

      double totalDistance = 0.0;

      // Calculating the total distance by adding the distance
      // between small segments
      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
         polylineCoordinates[i].longitude,
         polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }

      setState(() {
        _placeDistance = totalDistance.toStringAsFixed(2);
        print('DISTANCE: $_placeDistance km');
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
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points:polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
  }
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {currentPosition = position;
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 14.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          currentPosition.latitude, currentPosition.longitude);

      Placemark place = p[0];

      setState(() {currentAddress.value =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = currentAddress.value ;
        startAddress = currentAddress.value ;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = Get.size;
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            child: GetBuilder<HomeController>(
              builder: (controller) {
                return Container(
                    child:
                  Stack(
         children: <Widget>[
                  Container(
                      height: double.infinity,
                      child:
                      GoogleMap(
                        //markers: Set<Marker>.of(markers),
                        initialCameraPosition: initialLocation,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        mapType: MapType.normal,
                        onMapCreated: (GoogleMapController controller) {
                          mapController = controller;
                          _getCurrentLocation();
                        },
                      )),
                      SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child:
                      Container(
                        color: Colors.black12,
                        width:double.infinity,
                        height: size.height*0.1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: ()async {
                                if (isDriverAvailable!=true){
                                  print('Online Now');
                                  makeDriverOnlineNow();
                                  getLocationLiveUpdates();
                                  setState(() {
                                    driverStatusColor = Colors.green;
                                    driversStatusText="Online Now";
                                    isDriverAvailable=true;
                                  });
                                }
                                else {
                                  print('Offline Now - Go online');
                                  setState(() {
                                    driverStatusColor = Colors.black;
                                    driversStatusText="Offline Now - Go online";
                                    isDriverAvailable=false;
                                  });
                                  makeDriverOfflineNow();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      driversStatusText,
                                      style: CustomTextStyle.mediumTextStyle.copyWith(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Icon(
                                      Icons.phone_android,
                                      color: Colors.white,
                                    )
                                  ],
                                )
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: driverStatusColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            )],
                        )
                      ),
                    ),
                  ),
                      SafeArea(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(right: 10.0, bottom: 120.0),
                        child: ClipOval(
                          child: Material(
                            color: Colors.orange.shade100, // button color
                            child: InkWell(
                              splashColor: Colors.orange, // inkwell color
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: Icon(Icons.my_location),
                              ),
                              onTap: () {mapController.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(
                                        currentPosition.latitude,
                                        currentPosition.longitude,
                                      ),
                                      zoom: 18.0,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
       /*    Positioned(
               bottom: 50,
               left: 10,
               child: Slider(
                 min: 100.0,
                 max: 500.0,
                 divisions: 4,
                 value: radius.value,
                 label: 'Radius ${radius.value}km',
                 activeColor: Colors.green,
                 inactiveColor: Colors.green.withOpacity(0.2),
                 onChanged: updateQuery,
               )
           )*/
                ]));
              },
            ),
          ),
        ));
  }
/*  Future<DocumentReference>  makeDriverOnlineNow() async {
    Position position =await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition=position;
    GeoFirePoint point = geo.point(latitude: position.latitude, longitude: position.longitude);
    //rideRequestRef.set(point);
    return  firestore.collection('availableDriver').add({
      'position': point.data,
      'driverEmail':currentfirebaseUser.email,
      'driverUid': currentfirebaseUser.uid
    });
  }


  void updateMarkers(List<DocumentSnapshot> documentList) {
    print(documentList);
    //mapController.clearMarkers();
   // markers.clear();
    int id = Random().nextInt(500);
    documentList.forEach((DocumentSnapshot document) {
      GeoPoint pos = document.data()['position']['geopoint'];
      double distance = document.data()['distance'];
      var marker = Marker(
        markerId: MarkerId(id.toString()),
        position: LatLng(pos.latitude, pos.longitude),
        infoWindow: InfoWindow(
          title: 'Magic Marker'+'$distance kilometers from query center',
          //snippet:startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
      markers.add(Marker(
        markerId: MarkerId(id.toString()),
        position: LatLng(pos.latitude, pos.longitude),
        infoWindow: InfoWindow(
          title: 'Magic Marker'+'$distance kilometers from query center',
          //snippet:startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
      //mapController.addMarker(marker);
    });
  }*/
/*  startQuery() async {
    // Get users location
    Position position =await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition=position;
    double lat = position.latitude;
    double lng = position.longitude;


    // Make a referece to firestore
    var ref = firestore.collection('locations');
    GeoFirePoint center = geo.point(latitude: lat, longitude: lng);

    // subscribe to query
    print(markers);
    subscription = radius.switchMap((rad) {
      return geo.collection(collectionRef: ref).within(
          center: center,
          radius: rad,
          field: 'position',
          strictMode: true
      );
    }).listen(updateMarkers);
  }
  updateQuery(value) {
    setState(() {
      radius.add(value);
    });
  }*/
  void makeDriverOnlineNow() async {
 Position position =await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
   currentPosition=position;
    print(currentfirebaseUser.uid);
   Geofire.setLocation( currentfirebaseUser.uid,position.latitude, position.longitude);
    rideRequestRef.onValue.listen((event) {

    });
   rideRequestRef.onValue.listen((event) {
    });
  }
  void getLocationLiveUpdates(){
     homeDriverStreamSubcription = Geolocator.getPositionStream()
         .listen((Position position) {
          currentPosition = position;
         if (isDriverAvailable==true){
           Geofire.setLocation( currentfirebaseUser.uid,position.latitude, position.longitude);
         }
          //LatLng latLong = LatLng(position.latitude, position.longitude);
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 14.0,
              ),
            ),
          );
     });
  }
  void makeDriverOfflineNow(){
    Geofire.removeLocation(currentfirebaseUser.uid);
    rideRequestRef.onDisconnect();
    rideRequestRef.remove();
    rideRequestRef=null;
  }
}
