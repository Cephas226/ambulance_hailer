import 'package:get/get.dart';
import 'package:getx_app/pages/authentification/login.dart';
import 'package:getx_app/pages/home/home_page.dart';
import 'package:getx_app/pages/splash_screen/splash_screen.dart';
import 'package:getx_app/pages/splash_screen/splash_screen_binding.dart';

import 'app_routes.dart';

class AppPages {
  static var list = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomePage()
    ),
    GetPage(
        name: AppRoutes.LOGIN,
        page: () => Login()
    ),
    GetPage(
        name: AppRoutes.SPLASH_SCREEN,
        binding: SplashScreenBinding(),
        page: () => SplashScreen()
    ),
  ];
}
