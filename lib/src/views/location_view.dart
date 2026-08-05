import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/providers/location_provider.dart';
import 'package:provider/provider.dart';

class LocationView extends StatefulWidget {
  static const routeName = 'location';

  @override
  _LocationViewState createState() => _LocationViewState();
}

class _LocationViewState extends State<LocationView> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    changeStatusColor(pantoneEleven);
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(child: Container()),
                Icon(Icons.location_on, size: 100.0, color: Colors.grey[300]),
                SizedBox(
                  height: 40,
                ),
                text('Habilita tu ubicación', fontSize: textSizeNormal),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: text(
                      'Necesitas habilitar la opción de compartir ubicación para usar Physiho',
                      textColor: textSecondaryColor,
                      maxLine: null,
                      isCentered: true),
                ),
                Expanded(child: Container()),
                Center(
                  child: ElevatedButton(
                    style: TextButton.styleFrom(
                        foregroundColor: appColorAccent, shape: StadiumBorder()),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10.0),
                      child: Text('PERMITIR UBICACIÓN',
                          style: TextStyle(fontSize: 15.0)),
                    ),
                    onPressed: () {
                      _getCurrentLocation(context);
                    },
                  ),
                ),
                SizedBox(height: width * 0.3),
              ],
            ),
          ),
        ),
      ],
    ));
  }

  void _getCurrentLocation(context) {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((position) async {
      // Save current location
      Provider.of<LocationProvider>(context, listen: false)
          .setPosition(position);
    }).catchError((e) {
      print(e);
    });
  }
}
