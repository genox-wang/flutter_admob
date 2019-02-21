import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_admob/flutter_admob.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();  
    showAdMob();
  }


  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> showAdMob() async {
    if (Platform.isIOS) {
      try {
        await FlutterAdmob.init("ca-app-pub-3940256099942544~1458002511").then((_) {
          FlutterAdmob.showBanner("ca-app-pub-3940256099942544/2934735716", 
            size: Size.FULL_BANNER,
            gravity: Gravity.TOP,
            anchorOffset: 60,
          );
          // FlutterAdmob.showInterstitial("ca-app-pub-3940256099942544/4411468910");
          // FlutterAdmob.showRewardVideo("ca-app-pub-3940256099942544/1712485313");
        });
      } catch(e){
        print(e.toString());
      }
    } else if (Platform.isAndroid) {
      try {
        await FlutterAdmob.init("ca-app-pub-3940256099942544~3347511713").then((_) {
          // FlutterAdmob.showBanner("ca-app-pub-3940256099942544/6300978111", 
          //   size: Size.SMART_BANNER,
          //   gravity: Gravity.BOTTOM,
          //   anchorOffset: 60,
          // );
          FlutterAdmob.showInterstitial("ca-app-pub-3940256099942544/1033173712");
          // FlutterAdmob.showRewardVideo("ca-app-pub-3940256099942544/5224354917");
        });
      } catch(e){
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
