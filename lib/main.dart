import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ambulance_hailer/pages/DataHandler/appData.dart';
import 'package:firebase_core/firebase_core.dart';
import 'library/configMaps.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'themes/app_theme.dart';
import 'package:provider/provider.dart';
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //currentfirebaseUser =FirebaseAuth.instance.currentUser;
  var db = FirebaseDatabase.instance.reference().child("users");
  db.once().then((DataSnapshot snapshot){
    Map<dynamic, dynamic> values = snapshot.value;
    values.forEach((key,values) {
      if (values["userType"]=="Driver"){
        currentfirebaseDriver=FirebaseAuth.instance.currentUser;
      }
      else {
        currentfirebaseUser=FirebaseAuth.instance.currentUser;
      }
    });
  });
  runApp(MyApp());
}
DatabaseReference usersRef = FirebaseDatabase.instance.reference().child("users");
DatabaseReference rideRequestRef = FirebaseDatabase.instance.reference().child("users").child(currentfirebaseUser.uid).child("newRide");
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return
    ChangeNotifierProvider (
      create: (context)=>AppData(),
      child: GetMaterialApp(
        initialRoute: AppRoutes.SPLASH_SCREEN,
        getPages: AppPages.list,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Nunito'),
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.system,
    ));
  }
}
