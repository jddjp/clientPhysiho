// @dart=2.9
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:clientPhysiho/src/components/alert_widget.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/config/images.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/providers/cart_provider.dart';
import 'package:provider/provider.dart';

const apiKey = "AIzaSyBhDflq5iJrXIcKpeq0IzLQPQpOboX91lY";

class AddressConfirmation extends StatefulWidget {
  static const routeName = 'AddressConfirmation';

  @override
  AddressConfirmationState createState() => AddressConfirmationState();
}

class AddressConfirmationState extends State<AddressConfirmation> {
  Placemark lastAddress;
  Placemark currentAddress;
  LatLng currentLocation;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    changeStatusColor(whiteColor);
    lastAddress = context.watch<CartProvider>().getAddress(context);

    return Scaffold(
      backgroundColor: food_view_color,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            MapPage(
              onChange: (LatLng location) async {
                // Get address info
                Provider.of<CartProvider>(context, listen: false)
                    .calculateDeliveryData(userLocation: location);
                List<Placemark> placemarks = await placemarkFromCoordinates(
                    location.latitude, location.longitude);
                setState(() {
                  currentLocation = location;
                  currentAddress = placemarks[0];
                });
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                alignment: Alignment.center,
                height: width *
                    (context.watch<CartProvider>().hasService == false
                        ? 0.65
                        : 0.55),
                width: width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(spacing_standard),
                      topRight: Radius.circular(spacing_standard),
                    ),
                    color: food_white),
                padding: EdgeInsets.all(spacing_standard_new),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    context.watch<CartProvider>().hasService == false
                        ? AlertWidget(
                            bgColor: Colors.red,
                            alertText:
                                "Lo sentimos aún no tenemos cobertura en esta dirección.",
                          )
                        : Container(),
                    text("Configurar información de entrega:"),
                    SizedBox(
                      height: spacing_standard,
                    ),
                    text("Dirección",
                        textColor: food_textColorSecondary,
                        fontSize: textSizeSMedium),
                    currentAddress != null
                        ? text(
                            "${currentAddress.street}, ${currentAddress.subLocality}",
                            maxLine: null)
                        : text(
                            "${lastAddress.street}, ${lastAddress.subLocality}",
                            maxLine: null),
                    Container(
                      height: 0.5,
                      color: food_view_color,
                      width: width,
                      margin: EdgeInsets.only(
                          top: spacing_standard, bottom: spacing_standard_new),
                    ),
                    Row(
                      children: <Widget>[
                        /*Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                //launchScreen(context, FoodAddAddress.tag);
                              },
                              child: Container(
                                padding: EdgeInsets.only(top: spacing_standard, bottom: spacing_standard),
                                decoration: boxDecoration(color: food_textColorPrimary, radius: 50),
                                child: text("Agregar más detalles", isCentered: true),
                              ),
                            )),
                        SizedBox(
                          width: spacing_standard_new,
                        ),*/
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              //launchScreen(context, FoodAddAddress.tag);
                              if (currentLocation != null) {
                                Provider.of<CartProvider>(context,
                                        listen: false)
                                    .setAddress(context, currentLocation);
                              }
                              back(context);
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                  top: spacing_control,
                                  bottom: spacing_control),
                              decoration: boxDecoration(
                                  bgColor: food_colorPrimary, radius: 50),
                              child: text("Confirmar ubicación",
                                  textColor: food_white, isCentered: true),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MapPage extends StatefulWidget {
  final void Function(LatLng) onChange;

  MapPage({this.onChange});

  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  BitmapDescriptor pinLocationIcon;
  List<Marker> _markers = [];
  String currentAddress = '';
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), food_ic_map);
  }

  @override
  Widget build(BuildContext context) {
    LatLng pinPosition = context.watch<CartProvider>().getLocation(context);
    CameraPosition initialLocation =
        CameraPosition(zoom: 17, bearing: 30, target: pinPosition);

    return GoogleMap(
        myLocationEnabled: true,
        compassEnabled: true,
        markers: Set.from(_markers),
        onTap: _handleTap,
        initialCameraPosition: initialLocation,
        onMapCreated: (GoogleMapController controller) {
          //controller.setMapStyle(Utils.mapStyles);
          _controller.complete(controller);
          setState(() {
            _markers.add(Marker(
                markerId: MarkerId('value'),
                position: pinPosition /*, icon: pinLocationIcon*/));
          });
        });
  }

  _handleTap(LatLng tappedPoint) {
    // Trigger onChange location
    widget.onChange(tappedPoint);

    // Add marker to map
    setState(() {
      _markers = [];
      _markers.add(Marker(
          markerId: MarkerId(tappedPoint.toString()),
          position: tappedPoint,
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange)));
    });
  }
}

class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}
