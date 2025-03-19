// @dart=2.9
import 'dart:async';

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

  // Lista de opciones para el Dropdown (Clínica y Domicilio)
  final List<String> locationOptions = ["Clinica", "Domicilio"];
  // Variable para almacenar la opción seleccionada
  String selectedLocation;

  /// This implementation is just to simulate a load data behavior
  /// from a data base sqlite or from a API
  Future<void> _getValue() async {
    await Future.delayed(const Duration(seconds: 3), () {
      setState(() {
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
  String selectedDay;
  var hoursList = new List(15);
  final userPhysio = new SessionProvider();
  // String location = "consultorio";
  Map<String, dynamic> phisioSelected = null;
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

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
                      fontSize: 20,
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
                                          fontSize: textSizeMedium,
                                          fontWeight: fontSemibold,
                                        )),
                                    Text('Paquete:',
                                        style: TextStyle(
                                          fontSize: textSizeMedium,
                                          fontWeight: fontSemibold,
                                        )),
                                    Text('Costo:',
                                        style: TextStyle(
                                          fontSize: textSizeMedium,
                                          fontWeight: fontSemibold,
                                        )),
                                    Text('Sesiones:',
                                        style: TextStyle(
                                          fontSize: textSizeMedium,
                                          fontWeight: fontSemibold,
                                        )),
                                    Text('Tipo servicio:',
                                        style: TextStyle(
                                          fontSize: textSizeMedium,
                                          fontWeight: fontSemibold,
                                        ))
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_con.service['name'],
                                        style: TextStyle(
                                          fontSize: textSizeMedium,
                                          fontWeight: fontRegular,
                                        )),
                                    Text(_con.itemService['name'],
                                        style: TextStyle(
                                          fontSize: textSizeMedium,
                                          fontWeight: fontRegular,
                                        )),
                                    Text(
                                        '\$' +
                                            _con.itemService['price']
                                                .toString(),
                                        style: TextStyle(
                                          fontSize: textSizeMedium,
                                          fontWeight: fontSemibold,
                                        )),
                                    Text(_con.itemService['sesion'].toString(),
                                        style: TextStyle(
                                          fontSize: textSizeMedium,
                                          fontWeight: fontRegular,
                                        )),
                                    Text(_con.service['ubicacion'].toString(),
                                        style: TextStyle(
                                          fontSize: textSizeMedium,
                                          fontWeight: fontRegular,
                                        ))
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Text(
                                  'Selecciona una Ubicación',
                                  style: TextStyle(
                                    fontSize: textSizeNormal,
                                    fontWeight: fontBold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 22,
                                    ),
                                    SizedBox(width: 15),
                                    DropdownButton<String>(
                                      value: selectedLocation,
                                      hint: Text("Selecciona..."),
                                      elevation: 16,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 16),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.black,
                                      ),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          phisioSelected = null;
                                          selectedLocation = newValue;
                                          _con.selectedLocation = newValue;

                                          _con.asyncDataEmployes(newValue);
                                        });
                                      },
                                      items: locationOptions
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _con.service['name'].toString() == 'Dermatofuncional'
                              ? Container(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 16),
                                      Text('Fisioterapeuta Asignado:',
                                          style: TextStyle(
                                            fontSize: textSizeNormal,
                                            fontWeight: fontBold,
                                          )),
                                      Row(
                                        children: [
                                          Icon(Icons.person, size: 22),
                                          SizedBox(width: 15),
                                          // Display a label with the name of "María Fernanda Zamora López"
                                          Text(
                                            'María Fernanda Zamora López',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : _con.selectedLocation != null &&
                                      _con.employess.isNotEmpty
                                  ? Container(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 16,
                                          ),
                                          Text('Selecciona un Fisioterapeuta',
                                              style: TextStyle(
                                                fontSize: textSizeNormal,
                                                fontWeight: fontBold,
                                              )),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person,
                                                size: 22,
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              DropdownButton<
                                                  Map<String, dynamic>>(
                                                value: phisioSelected,
                                                hint: Text("Selecciona..."),
                                                elevation: 16,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16),
                                                underline: Container(
                                                  height: 2,
                                                  color: Colors.black,
                                                ),
                                                onChanged: (Map<String, dynamic>
                                                    value) {
                                                  setState(() {
                                                    phisioSelected =
                                                        value; // Actualiza el valor seleccionado
                                                    print(
                                                        phisioSelected); // Imprime el valor seleccionado
                                                  });
                                                },
                                                items: _con.employess.map<
                                                        DropdownMenuItem<
                                                            Map<String,
                                                                dynamic>>>(
                                                    (Map<String, dynamic>
                                                        value) {
                                                  return DropdownMenuItem<
                                                      Map<String, dynamic>>(
                                                    value: value,
                                                    child: Text(value['name']),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  : SizedBox(height: 16),
                          SingleChildScrollView(
                            child: Column(
                              children: [
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
                                      fontSize: textSizeMedium,
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
                                      if (_con.service['name'].trim() ==
                                          'Dermatofuncional') {
                                        setState(() {
                                          phisioSelected = {
                                            'id': 'deqVTO331NaMwusHQnK6f2rL4D2',
                                            'name':
                                                'María Fernanda Zamora López'
                                          };
                                        });
                                      }

                                      if (phisioSelected != null) {
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
                                              'idPhysio': phisioSelected['id'],
                                              'location': selectedLocation
                                            });
                                      } else {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Selecciona un Fisioterapeuta");
                                      }
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
                                        fontSize: textSizeMedium,
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
                      width: MediaQuery.of(context).size.width * 0.7,
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
                        validator: (value) {
                          if (value != null) {
                            if (sesionsList[index] !=
                                DateFormat('yyyy-MM-dd').format(value)) {
                              if (sesionsList.contains(
                                  DateFormat('yyyy-MM-dd').format(value))) {
                                sesionsList[index] = null;
                                return "Error: No puedes tener mas de una sesión al día.";
                              }
                              if (value.isBefore(DateTime.now())) {
                                sesionsList[index] = null;
                                return "Error: selecciona una fecha posterior a hoy.";
                              } else {
                                sesionsList[index] =
                                    DateFormat('yyyy-MM-dd').format(value);
                              }
                            }
                          }
                          return null;
                        },
                        onDateSelected: (DateTime value) {
                          selectedDate = value;
                          setState(() {
                            if (sesionsList.contains(
                                DateFormat('yyyy-MM-dd').format(value))) {
                              Fluttertoast.showToast(
                                  msg:
                                      "No puedes tener mas de una sesión al día, selecciona otra fecha");
                            } else {
                              sesionsList[index] =
                                  DateFormat('yyyy-MM-dd').format(value);

                              String selectedDayOfWeek =
                                  DateFormat('EEEE').format(value);

                              selectedDay = selectedDayOfWeek;
                            }
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
                    phisioSelected != null &&
                            _con.service['name'].trim() != 'Dermatofuncional'
                        ? FutureBuilder(
                            future: userPhysio.getHours(
                                index,
                                phisioSelected['id'],
                                sesionsList[index],
                                selectedDay),
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
                                return Container(
                                  width: 200,
                                  child: Text(
                                    'No se encuentra Disponible el horario',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  ),
                                );
                              }
                            },
                          )
                        : FutureBuilder(
                            future: userPhysio.getHours(
                                index,
                                'WdeqVTO331NaMwusHQnK6f2rL4D2',
                                sesionsList[index],
                                selectedDay),
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
                                return Container(
                                  width: 200,
                                  child: Text(
                                    'No se encuentra Disponible el horario',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  ),
                                );
                              }
                            },
                          )
                  ],
                )
              ],
            )),
      ),
    );
  }
}
