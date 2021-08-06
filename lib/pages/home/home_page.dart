import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_app/pages/alerts/pickup_user_page.dart';
import 'package:getx_app/pages/components/menu.dart';
import 'package:getx_app/utils/CustomTextStyle.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'home_controller.dart';

class HomePage extends GetView<HomeController> {

  var _ahmedabad = LatLng(23.0225, 72.5714);
  Set<Marker> markers = new Set();

  GoogleMapController mapController;
  BitmapDescriptor bitmapDescriptor;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (context) {
            return Container(
              child: Stack(
                children: <Widget>[
                  GoogleMap(
                    initialCameraPosition:
                    CameraPosition(target: _ahmedabad, zoom: 14),
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
                        alignment: Alignment.topRight,
                        child: Container(
                          child: IconButton(
                              icon: Icon(Icons.menu), onPressed: () {
                            showDialog(context: context,builder: (context){
                              return Menu();
                            });
                          }),
                        ),
                      ),
                      Card(
                        margin:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 10,
                                margin: EdgeInsets.only(left: 16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                                height: 10,
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 16),
                                  child: Text(
                                    "R.A Mel Mawatha",
                                    style: CustomTextStyle.regularTextStyle
                                        .copyWith(color: Colors.grey.shade800),
                                  ),
                                ),
                                flex: 100,
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.favorite_border,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                  onPressed: () {})
                            ],
                          ),
                        ),
                      ),
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
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8),bottomLeft: Radius.circular(8)),
                                    boxShadow: [
                                      BoxShadow(color: Colors.grey.shade400,blurRadius: 20,offset: Offset(-6, -10)),
                                      BoxShadow(color: Colors.grey.shade400,blurRadius: 20,offset: Offset(-6, 10))
                                    ]
                                ),
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
                        height: 20,
                      ),
                      RaisedButton(
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
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  void _onMapCreated(GoogleMapController mapController) {
    this.mapController = mapController;
  }
}

