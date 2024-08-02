

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yeotaskin/splash/splash.dart';
import 'package:yeotaskin/utilities/app_colors.dart';
import 'package:yeotaskin/utilities/navigator_key.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  requestPermissions();
  runApp(const MyApp());


}

Future<void> requestPermissions() async {
  debugPrint("Storage Permission");
  Map<Permission, PermissionStatus> status = await [
    Permission.storage,
  ].request();

  if (status[Permission.storage]!.isGranted) {
    debugPrint("Storage Permission Granted");
  } else {
    debugPrint("Storage Permission Not Granted");
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.light(primary: AppColors.primaryColor),
       useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      home:  const SplashScreen(),
      builder: EasyLoading.init(),
    );
  }
}

//Eve_Lee
// Evesl931017