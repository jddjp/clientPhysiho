// @dart=2.9
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clientPhysiho/src/components/check_type_payment.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/controllers/cart_controller.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/providers/login_provider.dart';
import 'package:clientPhysiho/src/providers/sessions_provider.dart';
import 'package:clientPhysiho/src/views/login_view.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'item';

  final Map<String, dynamic> item;

  ItemView({Key key, this.item}) : super(key: key);

  @override
  _ItemViewState createState() => _ItemViewState(item);
}

class _ItemViewState extends StateMVC<ItemView> {
  CartServiceController _con;

  _ItemViewState(Map<String, dynamic> item)
      : super(CartServiceController(item)) {
    _con = controller as CartServiceController;
  }

  SharedPreferences _idservices;
  bool loading = false;
  static final DateTime now = DateTime.now();

  GlobalKey<FormState> _oFormKey = GlobalKey<FormState>();
  TextEditingController _controller;

  //String _initialValue;
  String _valueToValidate = '';
  String _valueSaved = '';

  final List<Map<String, dynamic>> _items = [
    {
      'value': '9:00',
      'label': '9:00',
      'icon': Icon(Icons.stop),
    },
    {
      'value': 'circleValue',
      'label': 'Circle Label Loooooooooooooooooooong text',
      'icon': Icon(Icons.fiber_manual_record),
      'textStyle': TextStyle(color: Colors.red),
    },
    {
      'value': 'starValue',
      'label': 'Star Label',
      'enable': false,
      'icon': Icon(Icons.grade),
    },
  ];

  /// This implementation is just to simulate a load data behavior
  /// from a data base sqlite or from a API
  Future<void> _getValue() async {
    await Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        //_initialValue = 'circleValue';
        _controller.text = 'circleValue';
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initialize();
    //_initialValue = 'starValue';
    _controller = TextEditingController(text: 'starValue');

    _getValue();
  }

  void initialize() async {
    _idservices = await SharedPreferences.getInstance();
    setState(() {});
  }

  var sesionsList = new List(15);
  var hoursList = new List(15);
  final userPhysio = new SessionProvider();
  String location = "consultorio";

  @override
  Widget build(BuildContext context) {
    //_initialValue = 'starValue';

    //print(loading);
    //print(widget.item);
    var width = MediaQuery.of(context).size.width;
    //print('sesionList');
    //print(_idservices.getString('idservicio'));
    //print(_idservices.getString('idpaqueteservicio'));
    //print('ItemView');
    //print("pantalla de items compra?");
    //print(widget.item);
    //print(sesionsList);
    //print(hoursList);
// Change status bar color
    // print(userPhysio.getPhysio());
    changeStatusColor(Colors.transparent);
    return (context.watch<LoginProvider>().isLoggedIn() &&
            context.watch<LoginProvider>().currentUser['nombre'] != null
        ? Scaffold(
            appBar: AppBar(
                backgroundColor: pantoneTwo,
                title: Text(
                  "Detalle de Compra",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontFamily: 'Franklin Gothic'),
                )),
            body: _con.isLoading
                ? Container(
                    width: width,
                    child: Lottie.asset('assets/images/8682-loading.json'),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/fondoph.png"),
                            fit: BoxFit.cover)),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
/*                          Container(
                            margin: EdgeInsets.only(top: 50),
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'Detalle de Compra',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                          ),*/
                          Container(
                            padding: EdgeInsets.only(
                                left: 0.0, top: 30.0, bottom: 0, right: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Servicio:',
                                        style: TextStyle(
                                          fontSize: textSizeNormal,
                                          fontWeight: fontSemibold,
                                        )),
                                    Text('Paquete:',
                                        style: TextStyle(
                                          fontSize: textSizeNormal,
                                          fontWeight: fontSemibold,
                                        )),
                                    Text('Costo:',
                                        style: TextStyle(
                                          fontSize: textSizeNormal,
                                          fontWeight: fontSemibold,
                                        )),
                                    Text('Sesiones:',
                                        style: TextStyle(
                                          fontSize: textSizeNormal,
                                          fontWeight: fontSemibold,
                                        ))
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_con.service['name'],
                                        style: TextStyle(
                                          fontSize: textSizeNormal,
                                          fontWeight: fontRegular,
                                        )),
                                    Text(_con.itemService['name'],
                                        style: TextStyle(
                                          fontSize: textSizeNormal,
                                          fontWeight: fontRegular,
                                        )),
                                    Text(
                                        '\$' +
                                            _con.itemService['price']
                                                .toString(),
                                        style: TextStyle(
                                          fontSize: textSizeNormal,
                                          fontWeight: fontSemibold,
                                        )),
                                    Text(_con.itemService['sesion'].toString(),
                                        style: TextStyle(
                                          fontSize: textSizeNormal,
                                          fontWeight: fontRegular,
                                        ))
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _con.employee == null
                              ? Container(
                                  width: width,
                                  child: Lottie.asset(
                                      'assets/images/8682-loading.json'),
                                )
                              : Container(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Container(
                                        child: Text(
                                          'Fisioterapeuta',
                                          style: TextStyle(
                                            fontSize: textSizeLarge,
                                            fontWeight: fontSemibold,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text('Nombre:',
                                                  style: TextStyle(
                                                    fontSize: textSizeNormal,
                                                    fontWeight: fontBold,
                                                  )),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                  _con.employee == null
                                                      ? ''
                                                      : _con.employee['name'],
                                                  style: TextStyle(
                                                    fontSize: textSizeNormal,
                                                    fontWeight: fontRegular,
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        height: 30,
                                      ),
                                      CircleAvatar(
                                        backgroundColor: whiteColor,
                                        radius: width * 0.20,
                                        child: CachedNetworkImage(
                                          color: whiteColor,
                                          imageUrl: _con.employee['photo'],
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              color: whiteColor,
                                              borderRadius:
                                                  BorderRadius.circular(80),
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                                colorFilter: ColorFilter.mode(
                                                  Colors.black38
                                                      .withOpacity(0.9),
                                                  BlendMode.dstATop,
                                                ),
                                              ),
                                            ),
                                          ),
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                Divider(),
                                Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 30.0,
                                        top: 20.0,
                                        right: 30.0,
                                        bottom: 10.0),
                                    //apply padding to some sides only
                                    child: Text(
                                      '¿Dónde quieres recibir tus sesiones?',
                                      style: TextStyle(
                                        fontSize: textSizeNormal,
                                        fontWeight: fontBold,
                                      ),
                                    ),
                                  ),
                                ),
                                RadioListTile(
                                  title: Text("Consultorio",
                                      style: TextStyle(
                                        fontSize: textSizeNormal,
                                        fontWeight: fontRegular,
                                      )),
                                  value: "consultorio",
                                  groupValue: location,
                                  onChanged: (value) {
                                    setState(() {
                                      location = value.toString();
                                      print(location);
                                    });
                                  },
                                ),
                                RadioListTile(
                                  title: Text("A domicilio",
                                      style: TextStyle(
                                        fontSize: textSizeNormal,
                                        fontWeight: fontRegular,
                                      )),
                                  value: "domicilio",
                                  groupValue: location,
                                  onChanged: (value) {
                                    setState(() {
                                      location = value.toString();
                                      print(location);
                                    });
                                  },
                                ),
                                Container(
                                  height: 10,
                                ),
                                Divider(),
                                Text('Sesiones',
                                    style: TextStyle(
                                      fontSize: textSizeNormal,
                                      fontWeight: fontBold,
                                    )),
                                Container(
                                  decoration:
                                      BoxDecoration(color: Colors.transparent),
                                  child: ListView(
                                    shrinkWrap: true,
                                    primary: false,
                                    children: <Widget>[
                                      for (int i = 0;
                                          i < _con.itemService['sesion'];
                                          i++)
                                        listItem(
                                            index: i,
                                            title: "Sesión ${i + 1}",
                                            icon: Icons.calendar_today),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            color: pantoneTwo,
                            height: 10,
                          ),
                          Container(
                            color: pantoneTwo,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text('Continuar compra',
                                    style: TextStyle(
                                      fontSize: textSizeNormal,
                                      fontWeight: fontRegular,
                                    )),
                                ElevatedButton(
                                  style: TextButton.styleFrom(
                                    primary: pantoneThirteen,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                    ),
                                  ),
                                  onPressed: () {
                                    bool isFilled = true;
                                    for (int i = 0;
                                        i < _con.itemService['sesion'];
                                        i++) {
                                      if (sesionsList[i] == null) {
                                        isFilled = false;
                                      }
                                      if (hoursList[i] == null) {
                                        isFilled = false;
                                      }
                                    }
                                    if (isFilled) {
                                      launchScreen(
                                          context, CheckTypePayment.routeName,
                                          arguments: {
                                            'service': _con.service,
                                            'item': _con.itemService,
                                            'sesions': sesionsList,
                                            'hours': hoursList,
                                            'customer': context
                                                .read<LoginProvider>()
                                                .currentUser['id'],
                                            'idPhysio': _con.employee['id'],
                                            'location': location
                                          });
                                    } else {
                                      Fluttertoast.showToast(
                                          msg:
                                              "Selecciona la fecha y el horario de todas las sesiones");
                                    }
                                  },
                                  child: Text(
                                    'Siguiente',
                                    style: TextStyle(
                                        color: pantoneEight,
                                        fontSize: textSizeNormal,
                                        fontWeight: fontBold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            color: pantoneTwo,
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
          )
        : Scaffold(
            body: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff7c94b6),
                    backgroundBlendMode: BlendMode.color,
                    image: DecorationImage(
                        colorFilter: new ColorFilter.mode(
                            Colors.black.withOpacity(0.8), BlendMode.dstATop),
                        image: new AssetImage('assets/images/fondoph.png'),
                        fit: BoxFit.cover),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ListTile(
                          title: Text(
                            "Disfruta de nuestros servicios agenda y regístrate",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'Franklin Gothic',
                                fontWeight: fontSemibold),
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            launchScreen(context, LoginView.routeName);
                          },
                        ),
                        ListTile(
                          title: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: pantoneFive,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Text(
                              "Click aqui para registrarte",
                              style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 20,
                                  fontFamily: 'Franklin Gothic',
                                  fontWeight: fontSemibold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onTap: () {
                            launchScreen(context, LoginView.routeName);
                          },
                        ),
                      ],
                    )),
              ],
            ),
          ));
  }

  Widget listItem({int index, String title, IconData icon}) {
    return Material(
      color: Colors.transparent,
      child: Theme(
        data: ThemeData(accentColor: Colors.black),
        child: ExpansionTile(
          leading: Icon(
            icon,
            size: 40,
            color: pantoneFive,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: textSizeNormal,
              fontWeight: fontRegular,
            ),
          ),
          children: <Widget>[cardWidget(index)],
        ),
      ),
    );
  }

  Widget cardWidget(int index) {
    DateTime selectedDate;
    String selectedHour = '';
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0, bottom: 8),
        child: Container(
            width: MediaQuery.of(context).size.width * 0.91,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(1, 3),
                      color: Colors.grey[300],
                      blurRadius: 5),
                  BoxShadow(
                      offset: Offset(-1, -3),
                      color: Colors.grey[300],
                      blurRadius: 5)
                ]),
            child: Column(
              children: [
                index == 0
                    ? Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Text(
                            'Esta es tu primera sesión,selecciona un día despues de la compra '),
                      )
                    : Container(),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 22,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 250,
                      child: DateTimeFormField(
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(color: Colors.black45),
                          errorStyle: TextStyle(color: Colors.redAccent),
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.event_note),
                          labelText: 'Fecha de cita',
                        ),
                        mode: DateTimeFieldPickerMode.date,
                        autovalidateMode: AutovalidateMode.always,
                        validator: (e) => null,
                        onDateSelected: (DateTime value) {
                          selectedDate = value;
                          //print(value);
                          setState(() {
                            // print('setState');
                            // print(index);
                            sesionsList[index] =
                                DateFormat('yyyy-MM-dd').format(value);
                          });
                        },
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 22,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    FutureBuilder(
                      future: userPhysio.getHours(
                          index, _con.employee['id'], sesionsList[index]),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<dynamic>> snapshot) {
                        print('list hours');
                        print(snapshot.data);
                        if (snapshot.hasData) {
                          return Container(
                            width: 200,
                            child: SelectFormField(
                              key: Key(index.toString()),
                              type: SelectFormFieldType.dialog,
                              //controller: _controller,
                              //initialValue: _initialValue,
                              //icon: Icon(Icons.accessibility),
                              labelText: 'Hora',
                              changeIcon: true,
                              dialogTitle: 'Seleccionar horario',
                              dialogCancelBtn: 'Cancelar',
                              enableSearch: true,
                              dialogSearchHint: 'Buscar horario',
                              items: snapshot.data,
                              onChanged: (val) {
                                selectedHour = val;
                                setState(() {
                                  print("value changed: " + selectedHour);
                                  hoursList[index] = selectedHour;
                                  print(hoursList);
                                });
                              },
                              validator: (val) {
                                setState(() => _valueToValidate = val);
                                return null;
                              },
                              onSaved: (val) {
                                _valueSaved = val;
                                setState(() {});
                              },
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                )
              ],
            )),
      ),
    );
  }

  List<Map<String, dynamic>> _itemsHours() {
    List<Map<String, dynamic>> hoursList = new List();

    hoursList.add(
      {
        'value': '9:00',
        'label': '9:00 - 10:00',
        'icon': Icon(Icons.stop),
      },
    );
    hoursList.add(
      {
        'value': '10:30',
        'label': '10:30 - 11:30',
        'icon': Icon(Icons.stop),
      },
    );
    hoursList.add(
      {
        'value': '12:00',
        'label': '12:00 - 13:00',
        'icon': Icon(Icons.stop),
      },
    );
    hoursList.add(
      {
        'value': '13:30',
        'label': '13:30 - 14:30',
        'icon': Icon(Icons.stop),
      },
    );
    hoursList.add(
      {
        'value': '16:00',
        'label': '16:00 - 17:00',
        'icon': Icon(Icons.stop),
      },
    );
    hoursList.add(
      {
        'value': '17:30',
        'label': '17:30 - 18:30',
        'icon': Icon(Icons.stop),
      },
    );

    return hoursList;
  }
}
