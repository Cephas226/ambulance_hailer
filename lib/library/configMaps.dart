import 'dart:async';

import "package:firebase_auth/firebase_auth.dart";
import 'package:ambulance_hailer/models/allUsers.dart';
import 'package:geolocator/geolocator.dart';
User firebaseUser;
User currentfirebaseUser;
Users userCurrentInfo;
StreamSubscription <Position> homeDriverStreamSubcription;
final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final myApiKey = "AIzaSyAtzQc5uOLC9UcrPka0QHCsrpxx7Chxl0A";