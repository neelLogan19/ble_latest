//Total number of modules imported

import 'package:ble_diagnostic/pages/flash_diag_page.dart';

import 'package:ble_diagnostic/pages/full_diag_page.dart';

import 'package:ble_diagnostic/pages/status_page.dart';

import 'package:ble_diagnostic/pages/uart_page.dart';

import 'package:ble_diagnostic/utils/routes.dart';

import 'package:flutter/material.dart';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'dart:convert';

import 'dart:async'; // support for async programming with classes such as future and stream

import 'dart:io'
    show
        Platform; // porvides information such as os,hostname,enviroment variables
import 'package:location_permissions/location_permissions.dart';

class DataPage extends StatefulWidget {
  String name;
  var id;
  bool loader;
  StreamSubscription<ConnectionStateUpdate> streaming;
  DataPage(
      {required this.name,
      required this.id,
      required this.streaming,
      required this.loader});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {

  Future<bool> _onWillPop() async {
    return false; 
  }

  void initState() {
    widget.loader = false;
    super.initState();
  }

  var decoded;
  var resp;
  List<String> res = [];
  final Uuid serviceUuid = Uuid.parse("edd79b0f-4ae0-484a-8ba9-4a611f1cb47b");
  final Uuid characteristicUuid =
      Uuid.parse("9cc534f1-a27d-45be-bfd8-e28ddde624cb");

  final flutterReactiveBle = FlutterReactiveBle();
  //instance of bluetooth created
  void retrieveData(dev) async {
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceUuid,
        characteristicId: characteristicUuid,
        deviceId: dev);
    final response =
        await flutterReactiveBle.readCharacteristic(characteristic);
    decoded = utf8.decode(response);
    // print(response);
    print(decoded.toString());
    String ans = decoded.toString();
    print(ans);
    res.add(ans);
    print(res);
    setState(() {
      resp = decoded.toString();
      // res.add(ans);
    });
  }

  void streamingCancel() async {
    await widget.streaming.cancel();
    Navigator.pushNamed(context, MyRoutes.HomePage);
  }

  void goToUart(urtValue) async {
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceUuid,
        characteristicId: characteristicUuid,
        deviceId: widget.id);
    await flutterReactiveBle.writeCharacteristicWithResponse(characteristic,
        value: urtValue);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => UartDetails(uartpage1: true, id: widget.id)));
  }

  void goToStatus(statusValue) async {
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceUuid,
        characteristicId: characteristicUuid,
        deviceId: widget.id);
    await flutterReactiveBle.writeCharacteristicWithResponse(characteristic,
        value: statusValue);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => StatusDetails(statuspage2: true, id: widget.id)));
  }

  void goToFlash(flashValue) async {
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceUuid,
        characteristicId: characteristicUuid,
        deviceId: widget.id);
    await flutterReactiveBle.writeCharacteristicWithResponse(characteristic,
        value: flashValue);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => FlashDetails(flashpage3: true, id: widget.id)));
  }

  void goToFullScan(fullScanValue) async {
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceUuid,
        characteristicId: characteristicUuid,
        deviceId: widget.id);
    await flutterReactiveBle.writeCharacteristicWithResponse(characteristic,
        value: fullScanValue);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => FullDiagnostic(fullpage4: true, id: widget.id)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0085ba),
          automaticallyImplyLeading: false,
          title: Text('${widget.name}'),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                      textStyle: const TextStyle(
                    fontSize: 15,
                  )),
                  onPressed: streamingCancel,
                  child: Text(
                    "Disconnect",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(7.5),
          child: ListView(
            children: [
              SizedBox(height: 25),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                    color: Color(0xFFDFE4EA),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: Offset(0, 0))
                    ]),
                height: 100,
                child: Center(
                  child: ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.search,
                        size: 40,
                        color: Color(0xFF0085ba),
                      ),
                    ),
                    onTap: () {
                      var uartCmd = utf8.encode('{"BLE_URT":""}');
                      goToUart(uartCmd);
                    },
                    title: Text(
                      "UART",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                    color: Color(0xFFDFE4EA),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: Offset(0, 0))
                    ]),
                height: 100,
                child: Center(
                  child: ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.search,
                        size: 40,
                        color: Color(0xFF0085ba),
                      ),
                    ),
                    onTap: () {
                      var statusCmd = utf8.encode('{"BLE_SNS":""}');
                      goToStatus(statusCmd);
                    },
                    title: Text(
                      "STATUS",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                    color: Color(0xFFDFE4EA),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: Offset(0, 0))
                    ]),
                height: 100,
                child: Center(
                  child: ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.search,
                        size: 40,
                        color: Color(0xFF0085ba),
                      ),
                    ),
                    onTap: () {
                      var flashCmd = utf8.encode('{"BLE_FLS":""}');
                      goToFlash(flashCmd);
                    },
                    title: Text(
                      "FLASH",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                    color: Color(0xFFDFE4EA),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: Offset(0, 0))
                    ]),
                height: 100,
                child: Center(
                  child: ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.search,
                        size: 40,
                        color: Color(0xFF0085ba),
                      ),
                    ),
                    onTap: () {
                      var fullScanCmd = utf8.encode('{"BLE_FDM":""}');
                      goToFullScan(fullScanCmd);
                    },
                    title: Text(
                      "FULL SCAN",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
