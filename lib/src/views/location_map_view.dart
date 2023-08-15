// @dart=2.9
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/providers/login_provider.dart';
import 'package:clientPhysiho/src/providers/sessions_provider.dart';
import 'package:clientPhysiho/src/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class LocationMapView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'locationMap';

  LocationMapView({Key key}) : super(key: key);

  @override
  _LocationView createState() => _LocationView();
}

class _LocationView extends State<LocationMapView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/fondoph.png"),
              fit: BoxFit.cover)),
      child: MyHomePage(title: 'Ubicación'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {


   GoogleMapController mapController;

  final LatLng _center = const LatLng(-33.86, 151.20);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  @override
  Widget build(BuildContext context) {
    print('init');
    return Scaffold(
            appBar: AppBar(
              backgroundColor: pantoneFour,
              title: Center(child: Text(widget.title, style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontFamily: 'Franklin Gothic'),)),
            ),
            body:GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
            )



    );


          
  }
  Widget _buildButtons() {

    return GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 11.0,
    ),
    );

  }



}
