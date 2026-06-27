import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    _timer(context);
  }

  Future<void> checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (!mounted) {
      return;
    }

    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      _showToast('Mobile network available');
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      _showToast('Wi-Fi available');
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      _showToast('Ethernet available');
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      _showToast('VPN active');
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      _showToast('Bluetooth connection available');
    } else if (connectivityResult.contains(ConnectivityResult.satellite)) {
      _showToast('Satellite network available');
    } else if (connectivityResult.contains(ConnectivityResult.other)) {
      _showToast('Other network available');
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      _showToast('No network available');
    }
  }

  void _showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.lightGreenAccent,
      textColor: Colors.black,
      fontSize: 24,
    );
  }

  void _timer(BuildContext context) {
    Timer(
      const Duration(seconds: 3),
      () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SecondScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.cyanAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          tileMode: TileMode.mirror,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(child: Image.asset('android/assets/image/app_screen.png')),
          const SizedBox(height: 20),
          const SpinKitSpinningLines(color: Colors.pinkAccent),
        ],
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Screen')),
      body: const Center(
        child: Text(
          'This is a second screen.',
          style: TextStyle(
            fontSize: 24,
            color: Colors.amberAccent,
            fontWeight: FontWeight.w500,
            fontFamily: 'Alike',
          ),
        ),
      ),
    );
  }
}
