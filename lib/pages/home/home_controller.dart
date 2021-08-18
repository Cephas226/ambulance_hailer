import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

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