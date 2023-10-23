// import 'dart:async';
// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';

// Future<void> initialService() async {
//   final service = FlutterBackgroundService();
//   await service.configure(
//       iosConfiguration: IosConfiguration(
//         autoStart: true,
//         onForeground: onStart,
//         onBackground: onIosBack,
//       ),
//       androidConfiguration: AndroidConfiguration(
//           onStart: onStart, isForegroundMode: true, autoStart: true));
// }

// @pragma('vm:entry-point')
// dynamic onStart(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();
//   if (service is AndroidServiceInstance) {
//     service.on("setAsForeground").listen((event) {
//       service.setAsForegroundService();
//     });
//     service.on("setAsBackground").listen((event) {
//       service.setAsBackgroundService();
//     });
//   }
//   service.on("stopService").listen((event) {
//     service.stopSelf();
//   });
//   Timer.periodic(Duration(seconds: 1), (timer) async {
//     if (service is AndroidServiceInstance) {
//       if (await service.isForegroundService()) {
//         service.setForegroundNotificationInfo(
//             title: "Hi i am Batman", content: "i mean Vengeance");
//       }
//     }
//     // Perform some operation not noticiable to user
//     print('Background Service Running');
//     service.invoke("update");
//   });
// }

// @pragma('vm:entry-point')
// Future<bool> onIosBack(ServiceInstance instance) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();
//   return true;
// }
