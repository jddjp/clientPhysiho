// @dart=2.9
import 'dart:io';

import 'package:clientPhysiho/src/components/default_button.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/providers/get_states_m_provider.dart';
import 'package:clientPhysiho/src/providers/login_provider.dart';
import 'package:clientPhysiho/src/views/home_view.dart';
import 'package:clientPhysiho/src/views/login_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:direct_select/direct_select.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CompleteProfileView extends StatefulWidget {
  static const routeName = 'complete_profile';

  @override
  _CompleteProfileViewState createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  SharedPreferences _idservices;

  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];

  final states = new StatesMProvider().states();
  final municipalities = new StatesMProvider();
  final municipiosSelect = ["selecciona"];
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
  int flat = 0;

/**/

  final elements4 = ["selecciona"];
  int selectedIndex1 = 0,
      selectedIndex2 = 0,
      selectedIndex3 = 0,
      selectedIndex4 = 0;
  var estados = 'a';
  var municipios = 'a';

  var estadosUser = new LoginProvider().checkInfo();

  //*
  @override
  void initState() {
    super.initState();
    initialize();

    //_initialValue = 'starValue';
    _controller = TextEditingController(text: _valueSaved);
  }

  void initialize() async {
    _idservices = await SharedPreferences.getInstance();
    setState(() {});
  }

  // final estadosSelect = [];
  //estadosSelect
  List<Widget> _buildItemsestados(List<dynamic> elements) {
    return elements
        .map((val) => MySelectionItem(
              title: val,
            ))
        .toList();
  }

  List<Widget> _buildItemsmunicipios(List<dynamic> elements) {
    List<Widget> listMunicipios = new List();

    elements.forEach((element) {
      listMunicipios.add(MySelectionItem(
        title: element,
      ));
    });
    // selectedIndex2 = 0;
    return listMunicipios;

    // return elements
    //     .map((val) => MySelectionItem(
    //           title: val,
    //         ))
    //     .toList();
  }

  @override
  Widget build(BuildContext context) {
    print(estadosUser.toString());
    _valueChanged = context.watch<LoginProvider>().isLoggedIn() &&
            context.watch<LoginProvider>().currentUser['estado'] != null
        ? flat == 0
            ? context.watch<LoginProvider>().currentUser['estado']
            : _valueChanged
        : '';
    municipalities.municipio(_valueChanged);
    print("camino");
    print(context.watch<LoginProvider>().currentUser);
    print(context.watch<LoginProvider>().isLoggedIn());
    return Scaffold(
      body: (

          // context.watch<LoginProvider>().isLoggedIn() &&
          context.watch<LoginProvider>().currentUser != null
              ? LoadingOverlay(
                  isLoading: context.watch<LoginProvider>().currentUser == null,
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 40.0),
                              text("Completar perfil",
                                  fontSize: textSizeNormal),
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
    .currentUser['nombre'], readOnly: Platform.isIOS),
SizedBox(height: spacing_large),
buildEmailFormField(context
    .watch<LoginProvider>()
    .currentUser['correo'], readOnly: Platform.isIOS),


                                    SizedBox(height: spacing_large),
                                    buildPhoneNumberFormField(context
                                        .watch<LoginProvider>()
                                        .currentUser['telefono']),
                                    SizedBox(height: spacing_large),
                                    buildDireccionFormField(context
                                        .watch<LoginProvider>()
                                        .currentUser['direccion']),
                                    SizedBox(height: 40.0),
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
                                            'estado': _valueChanged,
                                            'municipio': municipio,
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
                                                HomeView.routeName
                                                /*_idservices.getString(
                                                            'idpaqueteservicio') !=
                                                        null &&
                                                    _idservices.getString(
                                                            'idservicio') !=
                                                        null
                                                ? ItemView.routeName
                                                : HomeView.routeName,*/
                                                ,
                                                (route) => false);
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.0),
                              GestureDetector(
                                onTap: () {
                                  context.read<LoginProvider>().logout();
                                },
                                child: Text(
                                  "Cerrar sesiÃ³n",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                              SizedBox(height: spacing_large),
                              Text(
                                "Al continuar, confirmas que estÃ¡ de acuerdo \ncon nuestros TÃ©rminos y condiciones",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.caption,
                              ),
                              SizedBox(height: spacing_large),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red, // Color rojo
                                ),
                                onPressed: () async {
                                  const url =
                                      'https://www.physiho.com/formulario-ios';
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    throw 'No se pudo abrir el enlace: $url';
                                  }
                                },
                                child: Text("Borrar Cuenta/Eliminar datos"),
                              ),
                              SizedBox(height: 20.0),
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
                                Colors.black.withOpacity(0.8),
                                BlendMode.dstATop),
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
                                "Disfruta de nuestros servicios agenda y regÃ­strate",
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
                )),
    );
  }

  Widget buildNameFormField(String defaultName, {bool readOnly = false}) {
  if (Platform.isIOS) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nombre:",
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          defaultName,
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  } else {
    return TextFormField(
      onSaved: (newValue) => name = newValue,
      initialValue: defaultName,
      autofocus: true,
      readOnly: readOnly,
      validator: (value) {
        if (value.isEmpty) {
          return "Por favor ingresa tu nombre";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Nombre",
        hintText: "Ingresa tu nombre completo",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}

Widget buildEmailFormField(String defaultValue, {bool readOnly = false}) {
  if (Platform.isIOS) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Correo electrónico:",
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          defaultValue,
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  } else {
    return TextFormField(
      initialValue: defaultValue,
      onSaved: (newValue) => email = newValue,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: "Correo electrónico",
        hintText: "Ingresa tu correo electrónico",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
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
          return "Ingresa tu nÃºmero de telÃ©fono";
        }
        if (!regex.hasMatch(value)) {
          return "Ingresa un nÃºmero a 10 dÃ­gitos vÃ¡lido";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "NÃºmero de telÃ©fono",
        hintText: "Ingresa tu nÃºmero de telÃ©fono",
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
          return "Por favor ingresa tu direcciÃ³n";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "DirecciÃ³n",
        hintText: "Ingresa tu direcciÃ³n",
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