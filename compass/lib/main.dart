import 'package:compass/neu_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasPermission = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchPermission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.brown[600],
        body: Builder(
          builder: (context) {
            if (_hasPermission) {
              return _buildCompass();
            } else {
              return _buildPermissionSheet();
            }
          },
        ),
      ),
    );
  }

  //compass Widget
  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          //error message
          if (snapshot.hasError) {
            return Text('Erorr Reading Heading: ${snapshot.error}');
          }
          //loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          double? direction = snapshot.data!.heading;
          //if direction is null , then device does not support this sensor
          if (direction == null) {
            return const Center(
              child: Text("This device does not supports sensors"),
            );
          }
          //return compass
          return NeuCircle(
            child: Transform.rotate(
              angle: direction * (math.pi / 180) * -1,
              child: Image.asset(
                "assets/compass2.png",
                color: Colors.white,
                fit: BoxFit.fill,
              ),
            ),
          );
        });
  }

  //permission widget sheet
  Widget _buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
          onPressed: () {
            Permission.locationWhenInUse
                .request()
                .then((value) => {_fetchPermission()});
          },
          child: const Text("Request Permission")),
    );
  }

  void _fetchPermission() {
    Permission.locationWhenInUse.status.then((status) => {
          if (mounted)
            {
              setState(() {
                _hasPermission = (status == PermissionStatus.granted);
              })
            }
        });
  }
}
