import 'package:clientPhysiho/src/config/colors.dart';
import 'package:flutter/material.dart';
import 'package:clientPhysiho/src/utils/my_navigator.dart';
import 'dart:async';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';

class SplashView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'splash';
  SplashView({Key key}) : super(key: key);

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () => MyNavigator.goToHome(context));
  }

  Widget build(BuildContext context) {
    //change status bar color
    changeStatusColor(whiteColor);
    return Scaffold(
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.asset(
            'assets/images/GifPhysiHo.gif',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          )),
    );
  }
}
