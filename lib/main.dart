import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MyApp());

}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      home: HomeScreen(),

    );

  }

}

class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {

  String status = "Press button to mark attendance";

  // ✅ YOUR ALLOWED LOCATION
  final double allowedLat = 31.25358;
  final double allowedLon = 75.6952082;

  // ✅ YOUR WIFI DETAILS
  final String allowedWifiName = "Linux";
  final String allowedWifiBSSID = "06:54:b2:ba:0a:43";


  Future<void> markAttendance() async {

    setState(() {

      status = "Checking...";

    });

    try {

      // LOCATION PERMISSION
      LocationPermission permission =
      await Geolocator.requestPermission();

      Position position =
      await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // FAKE GPS CHECK
      if (position.isMocked) {

        setState(() {

          status = "❌ Fake GPS detected";

        });

        return;

      }

      final info = NetworkInfo();

      String? wifiName = await info.getWifiName();

      wifiName = wifiName?.replaceAll('"', '');

      String? wifiBSSID = await info.getWifiBSSID();

      double distance = Geolocator.distanceBetween(

        allowedLat,
        allowedLon,
        position.latitude,
        position.longitude,

      );


      // PRINT DEBUG INFO
      print("--------- DEBUG ---------");

      print("Current Lat: ${position.latitude}");
      print("Current Lon: ${position.longitude}");

      print("Allowed Lat: $allowedLat");
      print("Allowed Lon: $allowedLon");

      print("Distance: $distance");

      print("Current WiFi: $wifiName");
      print("Allowed WiFi: $allowedWifiName");

      print("Current BSSID: $wifiBSSID");
      print("Allowed BSSID: $allowedWifiBSSID");

      print("-------------------------");


      // SHOW DEBUG INFO ON SCREEN
      setState(() {

        status =
        "Distance: $distance\n\n"
        "WiFi: $wifiName\n\n"
        "BSSID: $wifiBSSID";

      });



      // MAIN ATTENDANCE CONDITION
      if (

      distance <= 500 &&
          wifiName == allowedWifiName &&
          wifiBSSID == allowedWifiBSSID

      ) {


        // SAVE TO FIREBASE
        await FirebaseFirestore.instance
            .collection("attendance")
            .add({

          "latitude": position.latitude,
          "longitude": position.longitude,
          "wifiName": wifiName,
          "wifiBSSID": wifiBSSID,
          "time": DateTime.now(),

        });


        setState(() {

          status = "✅ Attendance Saved to Firebase";

        });



      }

      else {

        setState(() {

          status = "❌ Attendance Rejected\n\n"
              "Distance: $distance\n"
              "WiFi: $wifiName\n"
              "BSSID: $wifiBSSID";

        });

      }

    }

    catch (e) {

      setState(() {

        status = "Error: $e";

      });

    }

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text("Attendance System"),

      ),

      body: Center(

        child: Padding(

          padding: EdgeInsets.all(20),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              ElevatedButton(

                onPressed: markAttendance,

                child: Text(

                  "Mark Attendance",

                  style: TextStyle(fontSize: 18),

                ),

              ),

              SizedBox(height: 30),

              Text(

                status,

                textAlign: TextAlign.center,

                style: TextStyle(

                  fontSize: 16,

                  fontWeight: FontWeight.bold,

                ),

              )

            ],

          ),

        ),

      ),

    );

  }

}