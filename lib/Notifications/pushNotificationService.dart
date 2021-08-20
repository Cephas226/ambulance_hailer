import 'package:ambulance_hailer/library/configMaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../main.dart';

class PushNotificationService{
  final FirebaseMessaging firebaseMessaging=FirebaseMessaging();

  Future initialize() async {
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
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
}