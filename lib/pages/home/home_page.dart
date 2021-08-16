import 'dart:math';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:getx_app/assistant/assistantMethods.dart';
import 'package:getx_app/library/configMaps.dart';
import 'package:getx_app/library/place_request.dart';
import 'package:getx_app/pages/DataHandler/appData.dart';
import 'package:getx_app/pages/components/menu.dart';
import 'package:getx_app/pages/components/menu1.dart';
import 'package:getx_app/pages/trip/request_driver_trip.dart';
import 'package:getx_app/pages/trip/payment_dialog.dart';
import 'package:getx_app/utils/bottom_sheet.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:geolocator/geolocator.dart';

import 'home_controller.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Set<Marker> markers = new Set();
  HomeController hController = Get.put(HomeController());
  String _placeDistance;
  CameraPosition initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
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
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    GoogleMapsServices.getCurrentOnLineUserInfo();
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
              zoom: 18.0,
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
                        markers: Set<Marker>.from(markers),
                        initialCameraPosition: initialLocation,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        mapType: MapType.normal,
                        zoomGesturesEnabled: true,
                        zoomControlsEnabled: false,
                        polylines: Set<Polyline>.of(polylines.values),
                        onMapCreated: (GoogleMapController controller) {
                          mapController = controller;
                        },
                      )),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                          width: size.width * 0.9,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text("WHERE ARE YOU GOING ?",
                                    style: GoogleFonts.nunito(
                                      textStyle: TextStyle(
                                          color: Colors.black,
                                          letterSpacing: .1),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    )),
                                SizedBox(height: 10),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  child: TextFormField(
                                    style: GoogleFonts.nunito(
                                      textStyle: TextStyle(
                                          color: Colors.black,
                                          letterSpacing: .1),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    controller:startAddressController,
                                    focusNode:startAddressFocusNode,
                                    readOnly: true,
                                    onTap: () async {

                                    },
                                    decoration: const InputDecoration(
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      icon: FaIcon(
                                          FontAwesomeIcons.locationArrow,
                                          color: Colors.black),
                                      labelText: 'Actual position',
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  child: TextFormField(
                                    style: GoogleFonts.nunito(
                                      textStyle: TextStyle(
                                          color: Colors.black,
                                          letterSpacing: .1),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    controller:destinationAddressController,
                                    readOnly: true,
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PlacePicker(
                                            apiKey:myApiKey, // Put YOUR OWN KEY here.
                                            onPlacePicked: (result) {startAddressFocusNode.unfocus();
                                              destinationAddressFocusNode.unfocus();
                                              setState(() {
                                                if (markers.isNotEmpty)
                                                  markers.clear();
                                                if (polylines.isNotEmpty)
                                                  polylines.clear();
                                                if (polylineCoordinates
                                                    .isNotEmpty)polylineCoordinates.clear();
                                                _placeDistance = null;
                                              });

                                              _calculateDistance()
                                                  .then((isCalculated) {
                                                if (isCalculated) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Distance Calculated Sucessfully'),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Error Calculating Distance'),
                                                    ),
                                                  );
                                                }
                                              });
                                              Navigator.of(context).pop();
                                              destinationAddressController
                                                      .text =
                                                  result.formattedAddress;destinationAddress =destinationAddressController
                                                      .toString();
                                            },
                                            initialPosition: initialPosition,
                                            useCurrentLocation: true,
                                            selectInitialPosition: true,
                                          ),
                                        ),
                                      );
                                    },
                                    decoration: const InputDecoration(
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      icon: FaIcon(FontAwesomeIcons.search,
                                          color: Colors.black),
                                      labelText: 'Choose a destination',
                                    ),
                                    onChanged: (value) {destinationAddress = value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                      child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          child: IconButton(
                              icon: Icon(Icons.menu),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return MenuOnePage();
                                    });
                              }),
                        ),
                      ),
                      Spacer(),
                      Visibility(
                        visible: destinationAddress == '' ? false : true,
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.white),
                            height: 150,
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  child: SingleChildScrollView(
                                    physics: BouncingScrollPhysics(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          child: Row(children: [
                                            Text("👋 Hello Cephas ZOUBGA",
                                                style: GoogleFonts.nunito(
                                                  textStyle: TextStyle(
                                                      color: Colors.black,
                                                      letterSpacing: .1),
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900,
                                                ))
                                          ]),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.all(32.0),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20.0),
                                                    topRight:
                                                        Radius.circular(20.0)),
                                                color: Colors.grey.shade900,
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: <Widget>[
                                                      Text('DISTANCE: $_placeDistance km',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18.0),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Text(
                                                        "Price :" + " \$35.99",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18.0),
                                                      ),
                                                      Spacer(),
                                                      RaisedButton(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 8.0,
                                                                horizontal:
                                                                    16.0),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0)),
                                                        onPressed: () {
                                                        /*  showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return RequestTripPage();
                                                              });*/
                                                          /* showDialog(
                                                           context: context,
                                                           builder: (context) {
                                                             return RequestTripPage();
                                                           });*/
                                                          saveRideRequest();
                                                          showModalBottomSheet(
                                                            backgroundColor: Colors.transparent,
                                                            isScrollControlled: true,
                                                            context: context,
                                                            builder: (context) {
                                                              return BottomSheetContent();
                                                            },
                                                          );

                                                        },
                                                        color: Colors.red,
                                                        textColor: Colors.white,
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            Text(
                                                              "Validate",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      16.0),
                                                            ),
                                                            const SizedBox(
                                                                width: 20.0),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Icon(
                                                                Icons
                                                                    .arrow_forward_ios,
                                                                color:
                                                                    Colors.red,
                                                                size: 16.0,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0)),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            )),
                      )
                    ],
                  )),
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
                ]));
              },
            ),
          ),
        ));
  }
}
