import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location_screen.dart';

import 'advanced_location/location_example.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
        title: 'al azad',
        debugShowCheckedModeBanner: false,
        home: LocationExample());
  }
}
