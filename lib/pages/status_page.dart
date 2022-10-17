import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:convert';
import 'dart:async'; // support for async programming with classes such as future and stream
import 'dart:io'
    show
        Platform; // porvides information such as os,hostname,enviroment variables

import 'package:location_permissions/location_permissions.dart';

class StatusDetails extends StatefulWidget {
  bool statuspage2;
  var id;
  StatusDetails({required this.statuspage2, required this.id});

  @override
  State<StatusDetails> createState() => _StatusDetailsState();
}

class _StatusDetailsState extends State<StatusDetails> {
  Future<bool> _onWillPop() async {
    setState(() {
      disable = true;
    });
    var disableCmd = utf8.encode('{"BLE_DIS":""}');

    writeFunction(disableCmd, writableUuid);
    return true; //
  }
  void initState() {
    incMtu();
    startCounter(widget.id);
    //   Future.delayed(Duration(seconds: 3), () {

    // });
    super.initState();
  }

  var decoded;

  var resp;

  bool back = false;
  //by default true in the begning of the page
  bool disable = false;
  //pointer to handel duplication
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

  void startCounter(id) {
    Timer.periodic(Duration(milliseconds: 300), (timer) async {
      final characteristic = QualifiedCharacteristic(
          serviceId: serviceUuid,
          characteristicId: characteristicUuid,
          deviceId: id);
      final response = await flutterReactiveBle.readCharacteristic(
        characteristic,
      );
      print(response);
      // decoded = utf8.decode(response);
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
      if (back == true && disable == false) {
        timer.cancel();
        // Navigator.pop(context);
        // goBack();
      }
      if (disable) {
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
                back = true;
                // disable = true;
              });
              if (disable == false && back == true) {
                var disableCmd = utf8.encode('{"BLE_DIS":""}');
                writeFunction(disableCmd, writableUuid);
                Navigator.pop(context);
              }
              if (disable == true) {
                Navigator.pop(context);
              }
            },
               ),
          backgroundColor: Color(0xFF0085ba),
          centerTitle: true,
          title: Text("STATUS"),
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
            setState(() {
              disable = !disable;
            });
            if (disable == true) {
              //write request
              // const disable = '{"DISABLE_BLE_DIG":""}';
              var disableCmd = utf8.encode('{"BLE_DIS":""}');
    
              writeFunction(disableCmd, writableUuid);
            } else {
              //check for data type`
              ////write
              if (widget.statuspage2) {
                var uartCmd = utf8.encode('{"BLE_SNS":""}');
                writeFunction(uartCmd, writableUuid);
              }
    
              //read
              startCounter(widget.id);
            }
          },
          tooltip: 'Increment Counter',
          child: disable ? const Icon(Icons.play_arrow) : const Icon(Icons.pause),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
