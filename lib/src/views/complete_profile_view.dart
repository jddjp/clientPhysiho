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
  final elements4 = ["selecciona"];
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
        _controller.text = 'Selecciona Estado';
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

      var jsonResponse = jsonDecode(body);
      var itemCount = jsonResponse['response'];
      var itemCount2 = itemCount['estado'];

      print('Number of books about http: $itemCount.');
      for (var a in itemCount2) {
        estadosSelect.add(a);
      }

      print(estadosSelect);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> _getvalue2(dynamic selectedIndex1) async {
    await Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        //_initialValue = 'circleValue';
        _controller.text = 'Selecciona Municipio ';
        //'selecciona municipio';
      });
    });
    print(selectedIndex1);
    var url = 'https://api-sepomex.hckdrk.mx/query/get_municipio_por_estado/' +
        selectedIndex1;

    // Await the http get response, then decode the json-formatted response.
    // var response = await http.get(url);
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
      // var jsonResponse = jsonDecode(response.body);
      var itemCount = jsonResponse['response'];
      var itemCount2 = itemCount['municipios'];

      for (var a in itemCount2) {
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
                                              "Selecciona  Estado",
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
                                                    : context
                                                        .watch<LoginProvider>()
                                                        .currentUser['estado'],
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
                                              "Selecciona  Municipio",
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
                                                    : context
                                                        .watch<LoginProvider>()
                                                        .currentUser['municipio'],
                                              ),
                                              onSelectedItemChanged: (index) {
                                                setState(() {
                                                  selectedIndex2 = index;
                                                  print(municipiosSelect[
                                                      selectedIndex2]);
                                                  /* _getvalue2(estadosSelect[
                                                      selectedIndex1]); */
                                                });
                                              },
                                              mode: DirectSelectMode.tap,
                                              items: _buildItemsmunicipios() !=
                                                          null &&
                                                      _buildItemsmunicipios()
                                                              .length >
                                                          0
                                                  ? _buildItemsmunicipios()
                                                  : _buildItems4()),
                                          /*  DirectSelect(
                                              itemExtent: 35.0,
                                              selectedIndex: selectedIndex2,
                                              child: MySelectionItem(
                                                isForList: false,
                                                title: selectedIndex2 != 0
                                                    ? municipiosSelect[
                                                        selectedIndex2]
                                                    : context
                                                        .watch<LoginProvider>()
                                                        .currentUser['municipio'],
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
                                                  : _buildItems4()), */
                                        ]),
                                  ),
                                ),
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
