//Total number of modules imported
//1-  The dart::collection library is used to implement the collection of different data structures in dart 
import 'dart:collection';
//2- data page imported
import 'package:ble_diagnostic/pages/data_page.dart';
//3- This library is used to implement material designs in dart
import 'package:flutter/material.dart';
//4- a library module containing code that can be shared easily across multiple Flutter or Dart projects.
import 'package:flutter/services.dart';
//5- Flutter library that handles BLE operations for multiple devices.
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
 // support for async programming with classes such as future and stream
import 'dart:async';
// porvides information such as os,hostname,enviroment variables
import 'dart:io'
    show
        Platform; 
//provides location services to flutter application
import 'package:location_permissions/location_permissions.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //The future onwillpop function is used to exit the app if some one uses 
  //the in-built back functionality of the phone form the home page
  Future<bool> _onWillPop() async {
    SystemNavigator.pop();
    return true;
  }


//instance of flutter reactive bluetooth created
  final flutterReactiveBle =
      FlutterReactiveBle(); 

  // _scanStarted variable is set to true when scanning starts, when the scanning stop's this variable is again set to flase
  bool _scanStarted = false;

  //if we are connected to any device make _connected variable to true
  bool _connected = false;

  //this stream will help us listing all  the available  bluetooth devices
  late StreamSubscription<DiscoveredDevice> _scanStream;

  //This is a list and it will store all the discovered devices
  List<DiscoveredDevice> devicesList = [];

  // A hashset to prevent any duplicate device name from entering into the deviceList
  final hs = HashSet<String>();

  late Stream<BleStatus> statBle;
  // final BleStatus status;

  // flag to switch on/off the loader when connecting to a specific bluetooth device
  bool loader = false;

  bool search = true;

  //decoded value 
  String decodedByteArray = "";

  //this is the real data, byte array conversion to json data

  //used to fetch data from the ble device
  late QualifiedCharacteristic _rxCharacteristic;

  //connection state stream
  late StreamSubscription<ConnectionStateUpdate> _connection;

  // If there is no device available after scanning we print this message
  String _deviceMsg = "";

  //--> This flag is used to determine if we have devices which we can connect to or not 
  // when the scanning is completed and we have all the devices in the list this variable is set to true
  bool _foundDeviceWaitingToConnect = false;

  //serviceUid and characteristic uuid
  //The service uuid is used to search specific devices which contain this service uuid
  final Uuid serviceUuid = Uuid.parse("edd79b0f-4ae0-484a-8ba9-4a611f1cb47b");
  final Uuid characteristicUuid =
      Uuid.parse("d775dbdb-3b38-47be-9734-9ff022ba37ea");

  
 

  //This function is called on button click so that scanning for bluetooth device starts.
  void _startScan() async {
// Platform permissions handling for android and ios--> location permission
    bool permGranted = false;
    setState(() {
      _scanStarted = true;
    });
    PermissionStatus permission;
    if (Platform.isAndroid) {
      permission = await LocationPermissions().requestPermissions();
      if (permission == PermissionStatus.granted) permGranted = true;
    } else if (Platform.isIOS) {
      permGranted = true;
    }
// Main scanning logic -->here we add all devices into a list so that we can display it inside the body
    if (permGranted) {
      _scanStream = flutterReactiveBle
      // the array we can see in "withServices:----> [serviceUuid]--->, if we leave this array empty this scanning
      // function will give us all the advertising  devices, the service uuid is passed so that we get specific uuid"
          .scanForDevices(withServices: [serviceUuid]).listen((device) {
        //the device name we get is converted into a string
        String res = device.name.toString();
        //This is where we handle duplicacy of bluetooth device name via a Hashset 
        if (!hs.contains(res)) {
          devicesList.add(device);
          hs.add(res);
        }
        
        print("scan started");
   

        setState(() {
          _foundDeviceWaitingToConnect = true;
          _scanStarted = false;
        });

         //code for handling error in scanning 
      }, onError: (ErrorDescription) {
        // print(ErrorDescription);
      });
      //This timer method stops the scanning process in 3 seconds
      Timer(const Duration(seconds: 3), () {
        _scanStream.cancel();
      });
    }
  }

//----->  This function is used to connect to ble device
  void _connectToDevice(deviceIde, devName) {
    // The connectToAdvertisingDevice method takes the device id,serviceUuid and characteristicUuid to connect to a specific device 
    Stream<ConnectionStateUpdate> _currentConnectionStream = flutterReactiveBle
        .connectToAdvertisingDevice(
            id: deviceIde,
            prescanDuration: const Duration(seconds: 1),
            withServices: [serviceUuid, characteristicUuid]);
    _connection = _currentConnectionStream.listen((event) {
      // We can have 2 different switch cases of connection:-
      // 1 - > DeviceConnectionState = connected 
      // 2- > DeviceConnectionState = disconnected 

      switch (event.connectionState) {
        // We're connected and good to go!
        case DeviceConnectionState.connected:
          {
            _rxCharacteristic = QualifiedCharacteristic(
                serviceId: serviceUuid,
                characteristicId: characteristicUuid,
                deviceId: event.deviceId);
            print("good to go");
      

            print(_connection);
            // This string "nm" contains the device name of the device we are connected to
            String nm = devName.toString();
            //navigator.push method send us to the data page if the connection with the desired device was successfull
            //In our case we our transfering some states from the home page to the data page
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DataPage(
                      name: nm,
                      id: deviceIde,
                      streaming: _connection,
                      loader: loader,
                    )));
            final characteristic = QualifiedCharacteristic(
                serviceId: serviceUuid,
                characteristicId: characteristicUuid,
                deviceId: deviceIde);

            // retrieveData(deviceIde);
            print(decodedByteArray);



            setState(() {
              _connected = true;
              // loader = false;
              search = true;
              // _foundDeviceWaitingToConnect = false;
            });
            break;
          }
        // Can add various state  updates on disconnect
        case DeviceConnectionState.disconnected:
          {
            print("not good to go");
            setState(() {
              loader = false;
              search = true;
            });
            break;
          }
        default:
      }
    });
  }

  //User interface of the home page
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0085ba),
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            "Diagnostic App",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        // Body function logic
        //--> if the loader is set to true, this means that we are in a connecting state and the loader is visible to the user
        //--> if _foundDeviceWaitingToConnect is set to true and the device length is more than "0", this means that we 
        // have device to show.
        //--> if _foundDeviceWaitingToConnect or device length any one of the two doesn't meets the need of the given condition
        // this means that we have no device to show
        body: loader
            ? Center(
                child: new CircularProgressIndicator(
                  value: null,
                  strokeWidth: 7.0,
                ),
              )
            : Container(
                child: (_foundDeviceWaitingToConnect && devicesList.length > 0)
                    ? ListView.builder(
                        itemCount: devicesList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(devicesList[index].name),
                              subtitle: Text(devicesList[index].id),
                              trailing: Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                setState(() {
                                  loader = true;
                                  search = false;
                                });
                                _connectToDevice(devicesList[index].id,
                                    devicesList[index].name);
                              },
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          "No device found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
              ),
        floatingActionButton: Wrap(
          direction: Axis.horizontal,
          children: [
            _scanStarted
                ? Container(
                    margin: const EdgeInsets.all(10),
                    child: search
                        ? FloatingActionButton(
                            backgroundColor: Color(0xFF0085ba),
                            child: const Icon(Icons.search),
                            onPressed: _startScan,
                          )
                        : Container(),
                  )
                : Container(
                    margin: const EdgeInsets.all(10),
                    child: search
                        ? FloatingActionButton(
                            backgroundColor: Color(0xFF0085ba),
                            child: Icon(Icons.search),
                            onPressed: _startScan,
                          )
                        : Container(),
                  ),
          ],
        ),
      ),
    );
  }
}
