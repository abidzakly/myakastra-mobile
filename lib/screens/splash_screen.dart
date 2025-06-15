import 'package:flutter/material.dart';
import 'package:my_akastra_app/screens/account_screen.dart';
import 'package:my_akastra_app/screens/addVehicle_screen.dart';
import 'package:my_akastra_app/screens/myProfile_screen.dart';
import 'package:my_akastra_app/screens/vehicleList_screen.dart';
import 'dart:async';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/logo_akastra.png", width: 300),
            // SizedBox(height: 20),
            // CircularProgressIndicator(), // Loading indicator
          ],
        ),
      ),
    );
  }
}
