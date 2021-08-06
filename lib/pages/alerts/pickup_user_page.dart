import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_app/pages/alerts/pickup_controller.dart';

class PickupUserPage extends GetView<PickupUserController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            "Alerts Page",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
