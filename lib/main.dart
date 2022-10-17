import 'package:ble_diagnostic/pages/data_page.dart';
import 'package:ble_diagnostic/pages/home_page.dart';
import 'package:ble_diagnostic/utils/routes.dart';
import 'package:flutter/material.dart';

void main() {
  return runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: HomePage(),
      initialRoute: MyRoutes.HomePage,
      routes:{
        MyRoutes.HomePage:(context) => HomePage(),
      }
    );
  }
}
