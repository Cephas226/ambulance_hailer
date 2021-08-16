import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:getx_app/main.dart';
import 'package:getx_app/pages/home/home_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'myValadator.dart';

class AuthentificationController extends GetxController {
  List<bool> selectedToggleUserType=[false, false].obs;
  TextEditingController nameController;
  TextEditingController phoneController;
  TextEditingController passwordController;
  TextEditingController emailController;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Future<void> onInit() async {
    nameController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    emailController = TextEditingController();
    selectedToggleUserType = [false, false];
    super.onInit();
  }


  @override
  void onClose() {
    nameController?.dispose();
    phoneController?.dispose();
    passwordController?.dispose();
    emailController?.dispose();
  }
  bool validateCreds() {
    bool validated = false;
    if (MyValidators.nameValidator(nameController.text) == null &&
        MyValidators.phoneValidator(phoneController.text) == null &&
        MyValidators.passwordValidator(passwordController.text) == null &&
        MyValidators.emailValidator(emailController.text) == null &&
        selectedToggleUserType.contains(true)) {
      validated = true;
    } else {
      validated = false;
    }
    return validated;
  }
  void registerNewUser(context) async{
    if (validateCreds()) {
      final UserCredential authResult = (await _firebaseAuth.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text).catchError((errMsg){
        print("error");
      }));
      final User firebaseUser = authResult.user;
    if (firebaseUser != null){
        Map userDataMap ={
          "name":nameController.text.trim(),
          "email":emailController.text.trim(),
          "phone":phoneController.text.trim(),
          "userType":selectedToggleUserType.first
        };
        print(userDataMap);
        usersRef.child(firebaseUser.uid).set(userDataMap);
        Get.off(HomePage());
    }
    else {

    }
    }
  }
}
