import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:clientPhysiho/src/components/default_button.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/providers/login_provider.dart';
import 'package:clientPhysiho/src/views/home_view.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';

import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/providers/login_provider.dart';
import 'package:clientPhysiho/src/views/login_view.dart';
import '../config/colors.dart';
import '../providers/login_provider.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:direct_select/direct_select.dart';

class CompleteProfileView extends StatefulWidget {
  static const routeName = 'complete_profile';

  @override
  _CompleteProfileViewState createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];

  String name;
  String phoneNumber;
  String email;
  String direccion;
  String estado;
  String municipio;
  GlobalKey<FormState> _oFormKey = GlobalKey<FormState>();
  TextEditingController _controller;
  //String _initialValue;
  String _valueChanged = '';
  String _valueToValidate = '';
  String _valueSaved = '';
  String _valueChanged2 = '';
  String _valueToValidate2 = '';
  String _valueSaved2 = '';
/**/
  final elements1 = [
    "Breakfast",
    "Lunch",
    "2nd Snack",
    "Dinner",
    "3rd Snack",
  ];
  final elements2 = [
    "Cheese Steak",
    "Chicken",
    "Salad",
  ];

  final elements3 = [
    "7am - 10am",
    "11am - 2pm",
    "3pm - 6pm",
    "7pm-10pm",
  ];

  final elements4 = [
    "selecciona",
  ];
  int selectedIndex1 = 0,
      selectedIndex2 = 0,
      selectedIndex3 = 0,
      selectedIndex4 = 0;
//estadosSelect
  List<Widget> _buildItemsestados() {
    return estadosSelect
        .map((val) => MySelectionItem(
              title: val,
            ))
        .toList();
  }

  List<Widget> _buildItemsmunicipios() {
    return municipiosSelect
        .map((val) => MySelectionItem(
              title: val,
            ))
        .toList();
  }

  List<Widget> _buildItems1() {
    return elements1
        .map((val) => MySelectionItem(
              title: val,
            ))
        .toList();
  }

  List<Widget> _buildItems2() {
    return elements2
        .map((val) => MySelectionItem(
              title: val,
            ))
        .toList();
  }

  List<Widget> _buildItems3() {
    return elements3
        .map((val) => MySelectionItem(
              title: val,
            ))
        .toList();
  }

  List<Widget> _buildItems4() {
    return elements4
        .map((val) => MySelectionItem(
              title: val,
            ))
        .toList();
  }

/* */
  final List<Map<String, dynamic>> _items = [];
  final estadosSelect = [];
  final municipiosSelect = [];
  final List<Map<String, dynamic>> _items2 = [];
  @override
  void initState() {
    super.initState();

    //_initialValue = 'starValue';
    _controller = TextEditingController(text: _valueSaved);
    print(_valueSaved);
    _getValue();
  }

  /// This implementation is just to simulate a load data behavior
  /// from a data base sqlite or from a API
  Future<void> _getValue() async {
    await Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        //_initialValue = 'circleValue';
        _controller.text = 'selecciona estado';
      });
    });

    var url = 'https://api-sepomex.hckdrk.mx/query/get_estados';

    // Await the http get response, then decode the json-formatted response.
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    List<int> bytes = response.bodyBytes;
    if (response.statusCode == 200) {
      var body = utf8.decode(bytes);
      print(body);
      var jsonResponse = jsonDecode(body);
      var itemCount = jsonResponse['response'];
      var itemCount2 = itemCount['estado'];
      var itemCount3 = itemCount2[1]; //obtiene la posicion uno de la respuesta

      print('Number of books about http: $itemCount.');
      for (var a in itemCount2) {
        print(a);
        _items.add({
          'value': a,
          'label': a,
          //        'icon': Icon(Icons.stop),
          'icon': Icon(Icons.fiber_manual_record),
        });
        estadosSelect.add(a);
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> _getvalue2(dynamic selectedIndex1) async {
    await Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        //_initialValue = 'circleValue';
        _controller.text = 'selecciona estado';
      });
    });
    print(selectedIndex1);
    var url = 'https://api-sepomex.hckdrk.mx/query/get_municipio_por_estado/' +
        selectedIndex1;

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var itemCount = jsonResponse['response'];
      var itemCount2 = itemCount['municipios'];
      var itemCount3 = itemCount2[1]; //obtiene la posicion uno de la respuesta

      print('otra vez variable: $itemCount2.');
      print('otra vez variable: $itemCount3.');

      print('Number of books about http: $itemCount.');

      for (var a in itemCount2) {
        print(a);
        _items2.add({
          'value': a,
          'label': a,
          //        'icon': Icon(Icons.stop),
          'icon': Icon(Icons.fiber_manual_record),
        });
        print(_items);
        municipiosSelect.add(a);
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (context.watch<LoginProvider>().isLoggedIn() &&
              context.watch<LoginProvider>().currentUser['nombre'] != null
          ? LoadingOverlay(
              isLoading: context.watch<LoginProvider>().currentUser == null,
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: spacing_standard_new),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 40.0),
                          text("Completar perfil", fontSize: textSizeNormal),
                          Text(
                            "Completa tus datos para poder continuar",
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 45.0),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                buildNameFormField(context
                                    .watch<LoginProvider>()
                                    .currentUser['nombre']),
                                SizedBox(height: spacing_large),
                                buildPhoneNumberFormField(context
                                    .watch<LoginProvider>()
                                    .currentUser['telefono']),
                                SizedBox(height: spacing_large),
                                buildEmailFormField(context
                                    .watch<LoginProvider>()
                                    .currentUser['correo']),
                                SizedBox(height: spacing_large),
                                buildDireccionFormField(context
                                    .watch<LoginProvider>()
                                    .currentUser['direccion']),
                                SizedBox(height: 40.0),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Center(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Text(
                                              "Selecciona Estado",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          DirectSelect(
                                              itemExtent: 35.0,
                                              selectedIndex: selectedIndex1,
                                              child: MySelectionItem(
                                                isForList: false,
                                                title: selectedIndex1 != 0
                                                    ? estadosSelect[
                                                        selectedIndex1]
                                                    : 'selecciona',
                                              ),
                                              onSelectedItemChanged: (index) {
                                                setState(() {
                                                  selectedIndex1 = index;
                                                  print(estadosSelect[
                                                      selectedIndex1]);
                                                  _getvalue2(estadosSelect[
                                                      selectedIndex1]);
                                                });
                                              },
                                              mode: DirectSelectMode.tap,
                                              items: _buildItemsestados() !=
                                                          null &&
                                                      _buildItemsestados()
                                                              .length >
                                                          0
                                                  ? _buildItemsestados()
                                                  : _buildItems4()),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0, top: 20.0),
                                            child: Text(
                                              "Selecciona Municipio",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          DirectSelect(
                                              itemExtent: 35.0,
                                              selectedIndex: selectedIndex2,
                                              child: MySelectionItem(
                                                isForList: false,
                                                title: selectedIndex2 != 0
                                                    ? municipiosSelect[
                                                        selectedIndex2]
                                                    : 'selecciona',
                                              ),
                                              onSelectedItemChanged: (index) {
                                                setState(() {
                                                  selectedIndex2 = index;
                                                });
                                              },
                                              items: _buildItemsmunicipios()
                                                              .length >
                                                          0 &&
                                                      _buildItemsmunicipios() !=
                                                          null
                                                  ? _buildItemsmunicipios()
                                                  : _buildItems4()),
                                        ]),
                                  ),
                                ),

                                /* buildEstadoFormField(context
                                    .watch<LoginProvider>()
                                    .currentUser['estado']),
                                SizedBox(height: 40.0), */
                                /* buildMunicipioFormField(context
                                    .watch<LoginProvider>()
                                    .currentUser['municipio']),
                                SizedBox(height: 40.0),
                                SizedBox(height: 30),
                                 */

                                SizedBox(height: 30),
                                DefaultButton(
                                  text: "Continuar",
                                  press: () async {
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();

                                      await FirebaseFirestore.instance
                                          .collection('customers')
                                          .doc(context
                                              .read<LoginProvider>()
                                              .currentUser['id'])
                                          .update({
                                        'nombre': name,
                                        'telefono': phoneNumber,
                                        'correo': email,
                                        'direccion': direccion,
                                        'estado': estadosSelect[selectedIndex1],
                                        'municipio':
                                            municipiosSelect[selectedIndex2],
                                        'completed': true,
                                        'updated_at':
                                            FieldValue.serverTimestamp()
                                      });

                                      Provider.of<LoginProvider>(context,
                                              listen: false)
                                          .checkLoginState()
                                          .then((value) {
                                        // Redirect and remove all screens
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            HomeView.routeName,
                                            (route) => false);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: spacing_large),
                          Text(
                            "Al continuar, confirmas que está de acuerdo \ncon nuestros Términos y condiciones",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.caption,
                          ),
                          SizedBox(height: 80.0),
                          GestureDetector(
                            onTap: () {
                              context.read<LoginProvider>().logout();
                            },
                            child: Text(
                              "Cerrar sesión",
                              style: TextStyle(
                                  decoration: TextDecoration.underline),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 2),
                  child: ListTile(
                    title: Text(
                      "Iniciar Sesión",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'Franklin Gothic'),
                      textAlign: TextAlign.center,
                    ),
                    leading: Container(
                      margin: EdgeInsets.only(left: 100),
                      child: Icon(
                        Icons.account_circle_outlined,
                        color: appColorPrimary,
                      ),
                    ),
                    onTap: () {
                      launchScreen(context, LoginView.routeName);
                    },
                  ),
                ),
              ],
            )),
    );
  }

  TextFormField buildNameFormField(defaultName) {
    return TextFormField(
      onSaved: (newValue) => name = newValue,
      initialValue: defaultName,
      autofocus: true,
      validator: (value) {
        if (value.isEmpty) {
          return "Por favor ingresa tu nombre";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Nombre",
        hintText: "Ingresa tu nombre completo",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        //suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  TextFormField buildPhoneNumberFormField(String defaultValue) {
    return TextFormField(
      keyboardType: TextInputType.phone,
      initialValue: defaultValue,
      readOnly: defaultValue != null,
      onSaved: (newValue) => phoneNumber = newValue,
      validator: (value) {
        Pattern pattern = r'^[0-9]{10}$';
        RegExp regex = new RegExp(pattern);
        if (value.isEmpty) {
          return "Ingresa tu número de teléfono";
        }
        if (!regex.hasMatch(value)) {
          return "Ingresa un número a 10 dígitos válido";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Número de teléfono",
        hintText: "Ingresa tu número de teléfono",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        //suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
      ),
    );
  }

  TextFormField buildEmailFormField(String defaultValue) {
    return TextFormField(
      initialValue: defaultValue,
      onSaved: (newValue) => email = newValue,
      decoration: InputDecoration(
        labelText: "Correo electrónico",
        hintText: "Ingresa tu correo electrónico",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        //suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
      ),
    );
  }

  TextFormField buildDireccionFormField(defaultName) {
    return TextFormField(
      onSaved: (newValue) => direccion = newValue,
      initialValue: defaultName,
      autofocus: true,
      validator: (value) {
        if (value.isEmpty) {
          return "Por favor ingresa tu dirección";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Dirección",
        hintText: "Ingresa tu dirección",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        //suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  TextFormField buildEstadoFormField(defaultName) {
    return TextFormField(
      onSaved: (newValue) => estado = newValue,
      initialValue: defaultName,
      autofocus: true,
      validator: (value) {
        if (value.isEmpty) {
          return "Por favor ingresa tu estado";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Estado",
        hintText: "Ingresa tu Estado",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        //suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  TextFormField buildMunicipioFormField(defaultName) {
    return TextFormField(
      onSaved: (newValue) => municipio = newValue,
      initialValue: defaultName,
      autofocus: true,
      validator: (value) {
        if (value.isEmpty) {
          return "Por favor ingresa municipio";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Municipio",
        hintText: "Municipio",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        //suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }
}

/** */
//You can use any Widget
class MySelectionItem extends StatelessWidget {
  final String title;
  final bool isForList;

  const MySelectionItem({Key key, this.title, this.isForList = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: isForList
          ? Padding(
              child: _buildItem(context),
              padding: EdgeInsets.all(10.0),
            )
          : Card(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: Stack(
                children: <Widget>[
                  _buildItem(context),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.arrow_drop_down),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildItem(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: FittedBox(
          child: Text(
        title,
      )),
    );
  }
}
/*** */
