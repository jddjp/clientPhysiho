import 'package:clientPhysiho/src/components/check_type_payment.dart';
import 'package:clientPhysiho/src/controllers/cart_controller.dart';
import 'package:clientPhysiho/src/providers/sessions_provider.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clientPhysiho/src/components/item_option_widget.dart';
import 'package:clientPhysiho/src/components/stepper_counter.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/controllers/order_controller.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:clientPhysiho/src/providers/login_provider.dart';
import 'package:provider/provider.dart';
import 'package:clientPhysiho/src/views/login_view.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

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
    _con = controller;
  }
  SharedPreferences _idservices;
  bool loading = false;
  static final DateTime now = DateTime.now();

  GlobalKey<FormState> _oFormKey = GlobalKey<FormState>();
  TextEditingController _controller;

  //String _initialValue;
  String _valueChanged = '';
  String _valueToValidate = '';
  String _valueSaved = '';

  final List<Map<String, dynamic>> _items = [
    {
      'value': 'boxValue',
      'label': 'Box Label',
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
  final userPhysio = new SessionProvider();

  @override
  Widget build(BuildContext context) {
    //_initialValue = 'starValue';

    print(loading);
    //print(widget.item);
    var width = MediaQuery.of(context).size.width;
    print('sesionList');
    print(_idservices.getString('idservicio'));
    print(_idservices.getString('idpaqueteservicio'));
    print('ItemView');
    print("pantalla de items compra?");
    print(widget.item);
    print(sesionsList);
// Change status bar color
    changeStatusColor(Colors.transparent);
    return (context.watch<LoginProvider>().isLoggedIn() &&
            context.watch<LoginProvider>().currentUser['nombre'] != null
        ? Scaffold(
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
                            margin: EdgeInsets.only(top: 50),
                            padding: EdgeInsets.all(10),
                            child: Text('Detalle de Compra'),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Servicio:'),
                                    Text('Paquete:'),
                                    Text('Costo:'),
                                    Text('Sesiones:')
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_con.service['name']),
                                    Text(_con.itemService['name']),
                                    Text('\$' +
                                        _con.itemService['price'].toString()),
                                    Text(_con.itemService['sesion'].toString())
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                Text(
                                  'Sesiones',
                                  style: TextStyle(color: Colors.black),
                                ),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text('Seguimiento de compra'),
                                RaisedButton(
                                  onPressed: () {
                                    launchScreen(
                                        context, CheckTypePayment.routeName,
                                        arguments: {
                                          'service': _con.service,
                                          'item': _con.itemService,
                                          'sesions': sesionsList
                                        });
                                  },
                                  child: Text('Siguiente'),
                                )
                              ],
                            ),
                          )
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
                        fit: BoxFit.fill),
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
            style: TextStyle(fontSize: 17),
          ),
          children: <Widget>[cardWidget(index)],
        ),
      ),
    );
  }

  Widget cardWidget(int index) {
    print('card');
    print(index);
    DateTime selectedDate;
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
                Row(
                  children: [
                    Icon(
                      Icons.image_rounded,
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
                        validator: (e) =>
                            (e?.day ?? 0) <= now.day ? 'Fecha no valida' : null,
                        onDateSelected: (DateTime value) {
                          selectedDate = value;
                          print(value);
                          setState(() {
                            print('setState');
                            print(index);
                            sesionsList[index] = {index: value};
                            if (index == 0) {
                              print(userPhysio.getPhysio(value));
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
                      Icons.image_rounded,
                      size: 22,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 200,
                      child: SelectFormField(
                        type: SelectFormFieldType.dialog,
                        controller: _controller,
                        //initialValue: _initialValue,
                        icon: Icon(Icons.format_shapes),
                        labelText: 'Hora',
                        changeIcon: true,
                        dialogTitle: 'Pick a item',
                        dialogCancelBtn: 'CANCEL',
                        enableSearch: true,
                        dialogSearchHint: 'Search item',
                        items: _items,
                        onChanged: (val) => setState(() => _valueChanged = val),
                        validator: (val) {
                          setState(() => _valueToValidate = val);
                          return null;
                        },
                        onSaved: (val) => setState(() => _valueSaved = val),
                      ),
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}
