import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:getx_app/library/place_request.dart';
import 'package:getx_app/pages/alerts/pickup_user_page.dart';
import 'package:getx_app/pages/components/menu.dart';
import 'package:getx_app/pages/home/addressSearch.dart';
import 'package:getx_app/utils/CustomTextStyle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:uuid/uuid.dart';

import 'home_controller.dart';

class ResumeTransPage extends GetView<HomeController> {
  var initialPosition = LatLng(33.609434051916494, -7.623460799015407);
  Set<Marker> markers = new Set();

  GoogleMapController mapController;
  BitmapDescriptor bitmapDescriptor;
  final HomeController hController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    Size size = Get.size;
    return
      MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
      Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (context) {
            return Container(
              child:
              Stack(
                children: <Widget>[
                  Container(
                      height: double.infinity,
                      child:  GoogleMap(
                        initialCameraPosition:
                        CameraPosition(target: initialPosition, zoom: 14),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        markers: markers,
                        onMapCreated: _onMapCreated,
                      )),
                  SafeArea(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(children: [
                              MaterialButton(
                                padding: const EdgeInsets.all(8.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Icon(Icons.arrow_back_ios),
                                color: Colors.white,
                                textColor: Colors.black,
                                minWidth: 0,
                                height: 40,
                                onPressed: () => Navigator.pop(context),
                              ),
                            ]),
                          ),
                          Spacer(),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Colors.white),
                              child: Column(
                                children: <Widget>[
                                  const SizedBox(height: 30.0),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      physics: BouncingScrollPhysics(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          ListTile(
                                            title: Text(
                                              "Docside",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 28.0),
                                            ),
                                            trailing: IconButton(
                                              icon: Icon(Icons.favorite_border),
                                              onPressed: () {},
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0, vertical: 8.0),
                                            child: Text(
                                              "Hand-stitched finish. Flexible pebble sole. Made of brown leather with a textured effect",style: TextStyle(
                                                color: Colors.grey.shade600
                                            ),),
                                          ),
                                          ExpansionTile(
                                            title: Text("Show Details",style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold
                                            ),),
                                            children: <Widget>[
                                              Container(
                                                alignment: Alignment.topLeft,
                                                padding: const EdgeInsets.all(16.0),
                                                child: Text("This is the details widget. Here you can see more details of the product"),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(32.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20.0),
                                          topRight: Radius.circular(20.0)),
                                      color: Colors.grey.shade900,
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          "\$35.99",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 18.0),
                                        ),
                                        const SizedBox(width: 20.0),
                                        Spacer(),
                                        RaisedButton(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 16.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0)),
                                          onPressed: () {},
                                          color: Colors.orange,
                                          textColor: Colors.white,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text("Add to Cart",style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0
                                              ),),
                                              const SizedBox(width: 20.0),
                                              Container(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Colors.orange,
                                                  size: 16.0,
                                                ),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                    BorderRadius.circular(10.0)),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ))
                ],
              ),
            );
            /* Stack(
                children: <Widget>[
                  GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: initialPosition, zoom: 14),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: markers,
                    onMapCreated: _onMapCreated,
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          child: IconButton(
                              icon: Icon(Icons.menu),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Menu();
                                    });
                              }),
                        ),
                      ),
                      Container(
                        width: size.width * 0.8,
                        height: size.width * 0.1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.0),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                offset: Offset(1.0, 5.0),
                                blurRadius: 10,
                                spreadRadius: 3)
                          ],
                        ),
                        child: TextField(
                          readOnly: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlacePicker(
                                  apiKey:
                                      "AIzaSyC1ILfyVfqXrpgRDkfmA6SRPIwyBV2T7bE", // Put YOUR OWN KEY here.
                                  onPlacePicked: (result) {
                                    print(result.formattedAddress);
                                    hController.actualPositionController.text =
                                        result.formattedAddress;
                                    Navigator.of(context).pop();
                                  },
                                  initialPosition: HomePage().initialPosition,
                                  useCurrentLocation: true,
                                  selectInitialPosition: true,
                                ),
                              ),
                            );
                          },
                          cursorColor: Colors.black,
                          controller: hController.actualPositionController,
                          decoration: InputDecoration(
                            icon: Container(
                              margin: EdgeInsets.only(left: 20, top: 2),
                              width: 10,
                              height: 10,
                              child: Icon(
                                Icons.map,
                                color: Colors.black,
                              ),
                            ),
                            hintText: "pick up",
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.only(left: 15.0, top: 2.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                          alignment: Alignment.topCenter,
                          child: GestureDetector(
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlacePicker(
                                    apiKey:
                                        "AIzaSyC1ILfyVfqXrpgRDkfmA6SRPIwyBV2T7bE", // Put YOUR OWN KEY here.
                                    onPlacePicked: (result) {
                                      print(result.formattedAddress);
                                      hController.actualPositionController
                                          .text = result.formattedAddress;
                                      Navigator.of(context).pop();
                                    },
                                    initialPosition: HomePage().initialPosition,
                                    useCurrentLocation: true,
                                    selectInitialPosition: true,
                                  ),
                                ),
                              )
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 60),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                  ),
                                  Text("Select on map",
                                      style: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            color: Colors.white,
                                            letterSpacing: .1),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ))
                                ],
                              ),
                            ),
                          )),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        bottomLeft: Radius.circular(8)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.shade400,
                                          blurRadius: 20,
                                          offset: Offset(-6, -10)),
                                      BoxShadow(
                                          color: Colors.grey.shade400,
                                          blurRadius: 20,
                                          offset: Offset(-6, 10))
                                    ]),
                              )
                            ],
                          ),
                        ),
                        flex: 100,
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage("images/navigation.png"),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      *//*RaisedButton(
                        onPressed: () {
                          Navigator.of(context).push(new MaterialPageRoute(builder: (context)=>PickupUserPage()));
                        },
                        child: Text(
                          "I'm Here!",
                          style: CustomTextStyle.regularTextStyle
                              .copyWith(color: Colors.brown.shade400),
                        ),
                        padding:
                        EdgeInsets.symmetric(horizontal: 40, vertical: 4),
                        color: Colors.amber,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(24))),
                      ),*//*
                      Container(
                        width: size.width * 1,
                        height: size.width * 0.5,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            shape: BoxShape.rectangle),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text("WHERE ARE YOU GOING ?",
                                    style: GoogleFonts.nunito(
                                      textStyle: TextStyle(
                                          color: Colors.white,
                                          letterSpacing: .1),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ))
                              ],
                            ),
                            TextFormField(
                              controller:
                                  hController.destinationPositionController,
                              readOnly: true,
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlacePicker(
                                      apiKey:
                                          "AIzaSyC1ILfyVfqXrpgRDkfmA6SRPIwyBV2T7bE", // Put YOUR OWN KEY here.
                                      onPlacePicked: (result) {
                                        print(result.formattedAddress);
                                        hController
                                            .destinationPositionController
                                            .text = result.formattedAddress;
                                        Navigator.of(context).pop();
                                      },
                                      initialPosition:
                                          HomePage().initialPosition,
                                      useCurrentLocation: true,
                                      selectInitialPosition: true,
                                    ),
                                  ),
                                );
                              },
                              decoration: const InputDecoration(
                                labelStyle: TextStyle(color: Colors.white),
                                icon: Icon(Icons.search, color: Colors.white),
                                labelText: 'Choose a destination',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white),
                    child:
                    Column(
                      children: <Widget>[
                        const SizedBox(height: 30.0),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  title: Text(
                                    "Docside",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28.0),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.favorite_border),
                                    onPressed: () {},
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: Text(
                                    "Hand-stitched finish. Flexible pebble sole. Made of brown leather with a textured effect",
                                    style: TextStyle(
                                        color: Colors.grey.shade600),
                                  ),
                                ),
                                ExpansionTile(
                                  title: Text(
                                    "Show Details",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.topLeft,
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                          "This is the details widget. Here you can see more details of the product"),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(32.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0)),
                            color: Colors.grey.shade900,
                          ),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "\$35.99",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                              const SizedBox(width: 20.0),
                              Spacer(),
                              RaisedButton(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10.0)),
                                onPressed: () {},
                                color: Colors.orange,
                                textColor: Colors.white,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      "Add to Cart",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0),
                                    ),
                                    const SizedBox(width: 20.0),
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.orange,
                                        size: 16.0,
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0)),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),*/
          },
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController mapController) {
    this.mapController = mapController;
  }
}
