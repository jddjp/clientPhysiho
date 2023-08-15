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
              image: AssetImage("assets/images/food_ic_map.png"),
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
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  final LatLng _center = const LatLng(24.821616866968533, -107.38899707242675);

  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    addCustomIcon();
    super.initState();
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(), "assets/images/launcher_iconph.png")
        .then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    final marker = Marker(
      markerId: MarkerId('Market'),
      position:  LatLng(24.821616866968533, -107.38899707242675),
    //  icon: markerIcon,
      infoWindow: InfoWindow(
        title: 'Physiho Consultorio',
        snippet:
            'C. Josefa Ortiz de Domínguez #571-Local 12, Chapultepec, 80040 Culiacán Rosales, Sinaloa.',
      ),
    );

    setState(() {
      markers[MarkerId('Market')] = marker;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('init');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pantoneFour,
        title: Center(
            child: Text(
          widget.title,
          style: TextStyle(
              color: Colors.black, fontSize: 25, fontFamily: 'Franklin Gothic'),
        )),
      ),
      body:
       GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 14.0,
        ),
        markers: markers.values.toSet(),
      ),
    );
  }


}
