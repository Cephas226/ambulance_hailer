import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeController extends GetxController {

  final actualPositionController  = TextEditingController();
  final destinationPositionController = TextEditingController().obs;
  static LatLng _initialPosition;
  LatLng get initialPosition => _initialPosition;
  LatLng get lastPosition => _lastPosition;
  LatLng _lastPosition = _initialPosition;
  bool locationServiceActive = true;
  Position _center;
  @override
  void dispose() {
    destinationPositionController.value.dispose();
    super.dispose();
  }
  @override
  Future<void> onInit() async {
    _getUserLocation();
    _loadingInitialPosition();
    super.onInit();
  }
  void _getUserLocation() async {
    print("GET USER METHOD RUNNING =========");
   Position position = await Geolocator.getCurrentPosition();
    _initialPosition = LatLng(position.latitude, position.longitude);
    List<Placemark> placemark = await placemarkFromCoordinates(
        position.latitude,
        position.longitude
    );
    actualPositionController.text = placemark[0].street;
    print("initial position is : ${_initialPosition.toString()}");
  }

  void _loadingInitialPosition()async{
    await Future.delayed(Duration(seconds: 5)).then((v) {
      if(actualPositionController == null){
        locationServiceActive = false;
      }
    });
  }
}
