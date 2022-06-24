import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:tls_test_app_beacon/show_lotification.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ' Test Beacon',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Test Beacon'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  Region? currentRegio;
  var regions = <Region>[];
  TextEditingController UUID = new TextEditingController();
  TextEditingController minor = new TextEditingController();
  TextEditingController major = new TextEditingController();
  StreamSubscription<MonitoringResult>? _monitorStream ;
  StreamSubscription<RangingResult>? _rangingStream ;
  String state = "Stopped";
  List<Beacon> beacons = [];
  ShowNotificationUtils showNotificationUtils = new ShowNotificationUtils();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showNotificationUtils.initNotification();
    WidgetsBinding.instance!.addObserver(this);
    initBeacon();

  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  Future<void> initBeacon() async {
    try {
      print("check");
      await flutterBeacon.initializeAndCheckScanning;
    } on PlatformException catch (e) {
      // library failed to initialize, check code and message
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // if(currentRegio!=null){
        //   if(_monitorStream!=null){
        //     _monitorStream!.cancel();
        //   }
        //   startScannBeaconForeground(currentRegio!);
        // }
        break;
      case AppLifecycleState.inactive:
        // if(_rangingStream!=null){
        //   _rangingStream!.cancel();
        // }
        // if(currentRegio!=null){
        //   startScannBeaconBackgroundground(currentRegio!);
        // }
        break;
      case AppLifecycleState.paused:

        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
  }

  void startScannBeaconForeground(Region region){
    if(_rangingStream!=null){
      // to start ranging beacons
      _rangingStream!.cancel();
    }
    // to start ranging beacons
    _rangingStream = flutterBeacon.ranging([region]).listen((RangingResult result) {
     print("ranging event ${result.toJson}");
     if(result.beacons.isNotEmpty){
       setState(() {
         beacons = result.beacons;
       });
       showNotificationUtils.showNotifiCationBeacon(beacons[0]);
     }
    });
  }

  void startScannBeaconBackgroundground(Region region){
    if(_monitorStream!=null){
      // to start ranging beacons
      _monitorStream!.cancel();
    }
    // to start ranging beacons
    print("start monitor");
    _monitorStream = flutterBeacon.monitoring([region]).listen((MonitoringResult result) {
      print("monitor event ${result.toJson}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 30),
            Text(" Region is being searching: \n" +
                (currentRegio != null
                    ? " major: ${currentRegio?.major??""} \n minor: ${currentRegio?.minor??""}"
                    " \n UUID: ${currentRegio?.proximityUUID??""} \n identify: ${currentRegio?.identifier??""} "
                    : "Empty")),
            SizedBox(height: 10),
            Form(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...textFieldInput(UUID, "UUID"),
                    ...textFieldInput(minor, "Minor",isNumber: true),
                    ...textFieldInput(major, "Major", isNumber: true),
                    SizedBox(height: 20),
                    Align(
                        alignment: Alignment.center,
                        child: Text(state, style: TextStyle(fontSize: 30))),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          if (UUID.text.trim().isNotEmpty &&
                              minor.text.trim().isNotEmpty &&
                              major.text.trim().isNotEmpty) {

                            var uuid = UUID.text.trim();
                            var maj = major.text.trim();
                            var mir = minor.text.trim();
                            Region r ;
                            if (Platform.isIOS) {
                              // iOS platform, at least set identifier and proximityUUID for region scanning
                              r = new Region(identifier: uuid, proximityUUID: uuid, major: int.parse(maj), minor: int.parse(mir));
                            } else {
                              // android platform, it can ranging out of beacon that filter all of Proximity UUID
                              r = Region(identifier: uuid);
                            }
                            setState(() {
                              currentRegio = r;
                              state = "Scanning";
                            });
                            startScannBeaconForeground(currentRegio!);
                          } else {
                            // set up the AlertDialog
                            AlertDialog alert = AlertDialog(
                              content: Text("Please input full information."),
                              actions: [
                                GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("OK",
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.blue)))
                              ],
                            );
                            // show the dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: alert,
                                );
                              },
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(15)),
                          child: Text("Scan",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25)),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: (){
                          if(_rangingStream!=null){
                            _rangingStream!.cancel();
                          }
                          setState(() {
                            state = "Stopped";
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(15)),
                          child: Text("Stop scanner",
                              style:
                              TextStyle(color: Colors.white, fontSize: 25)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                        alignment: Alignment.center,
                        child: Text("List beacon found", style: TextStyle(fontSize: 20))),
                    SizedBox(height: 10),
                    if(beacons.isNotEmpty)
                      ListView.builder(itemBuilder: (context, index){
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("${beacons[index].toJson}"),
                        );
                      })
                  ],

                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> textFieldInput(TextEditingController controller, String title, {bool isNumber =false}) {
    return [
      const SizedBox(height: 10),
      Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey)),
        child: TextField(
              keyboardType:isNumber? TextInputType.number:TextInputType.text,
            controller: controller,
            decoration: InputDecoration(border: InputBorder.none,contentPadding: EdgeInsets.symmetric(horizontal: 8))),
      )
    ];
  }
}
