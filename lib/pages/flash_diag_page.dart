import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:convert';
import 'dart:async'; // support for async programming with classes such as future and stream
import 'dart:io'
    show
        Platform; // porvides information such as os,hostname,enviroment variables

import 'package:location_permissions/location_permissions.dart';

class FlashDetails extends StatefulWidget {
  bool flashpage3;
  var id;
  FlashDetails({required this.flashpage3, required this.id});

  @override
  State<FlashDetails> createState() => _FlashDetailsState();
}

class _FlashDetailsState extends State<FlashDetails> {
  Future<bool> _onWillPop() async {
    setState(() {
      refresh = true;
    });
    var disableCmd = utf8.encode('{"BLE_DIS":""}');

    writeFunction(disableCmd, writableUuid);
    return true; //
  }
  void initState() {
    incMtu();
    startCounter(widget.id);

    super.initState();
  }

  var decoded;

  var resp;


  var refresh = false;
  var curr;
  var prev;

  List<String> res = [];
  // final hs = HashSet<String>();
  final Uuid serviceUuid = Uuid.parse("edd79b0f-4ae0-484a-8ba9-4a611f1cb47b");
  final Uuid characteristicUuid =
      Uuid.parse("d775dbdb-3b38-47be-9734-9ff022ba37ea");
  final Uuid writableUuid = Uuid.parse("9cc534f1-a27d-45be-bfd8-e28ddde624cb");
  final flutterReactiveBle = FlutterReactiveBle();
  // var counter = 10;
  void incMtu() async {
    await flutterReactiveBle.requestMtu(deviceId: widget.id, mtu: 512);
  }

  void startCounter(id) async {
    Timer.periodic(Duration(milliseconds: 300), (timer) async {
      final characteristic = QualifiedCharacteristic(
          serviceId: serviceUuid,
          characteristicId: characteristicUuid,
          deviceId: id);
      final response = await flutterReactiveBle.readCharacteristic(
        characteristic,
      );

      print(response);
       try {
        decoded = utf8.decode(response);
      } catch (e) {
        print(e);
      }

      String ans = decoded.toString();
      print(ans);
      curr = ans;
      if (curr != prev) {
        //adding to array
        res.add(curr);
        res.add("\n");
        res.add("\n");
        prev = curr;
      } else {
        prev = curr;
      }

      print(res);
   
      if (refresh) {
        timer.cancel();
      }

      if (mounted) {
        setState(() {
          resp = res.toString();
        });
      }
    });
  
  }

  void writeFunction(statusValue, writeId) async {
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceUuid, characteristicId: writeId, deviceId: widget.id);
    await flutterReactiveBle.writeCharacteristicWithoutResponse(characteristic,
        value: statusValue);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: BackButton(
            onPressed: () {
              setState(() {
                refresh = true;
              });
              var disableCmd = utf8.encode('{"BLE_DIS":""}');
              print(disableCmd.length);
              writeFunction(disableCmd, writableUuid);
              Navigator.pop(context);
            },
          ),
          backgroundColor: Color(0xFF0085ba),
          centerTitle: true,
          title: Text("FLASH"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              child: Text(
                res.toString().length <= 5 ? "" : res.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
    
        //bottom button to disable and play
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          child: Container(height: 50.0),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFF0085ba),
          onPressed: () {
            //refresh true
            setState(() {
              refresh = true;
            });
            var disableCmd = utf8.encode('{"BLE_DIS":""}');
            writeFunction(disableCmd, writableUuid);
            var uartCmd = utf8.encode('{"BLE_FLS":""}');
            writeFunction(uartCmd, writableUuid);
            //refresh false
            setState(() {
              refresh = false;
            });
            startCounter(widget.id);
    
          },
          tooltip: 'Increment Counter',
          child: const Icon(Icons.refresh),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
