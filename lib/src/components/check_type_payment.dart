import 'dart:convert';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/providers/sessions_provider.dart';
import 'package:clientPhysiho/src/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;
import 'package:openpay_bbva/openpay_bbva.dart';

class CheckTypePayment extends StatefulWidget {
  static const routeName = 'paymentType';

  final Map<String, dynamic> item;

  CheckTypePayment({Key? key, required this.item}) : super(key: key);

  @override
  _CheckTypePaymentState createState() => _CheckTypePaymentState(item);
}

class _CheckTypePaymentState extends State<CheckTypePayment> {
  _CheckTypePaymentState(Map<String, dynamic> item);

  Map<String, dynamic> paymentTypes = {
    'cash': {
      'title': 'Pago en efectivo',
      'subtitle': 'Al recibir tu pedido',
      'secondary': Image.asset("assets/images/pago.png")
    },
    'online': {
      'title': 'Pago con tarjeta',
      'subtitle': 'Con Tarjeta ',
      'secondary': Image.asset(
        "assets/images/pagotarjeta.png",
        width: 55,
        height: 40,
      ),
    },
  };

  final userPhysio = SessionProvider();
  String _selectedPayment = 'cash';
  bool isLoading = false;



  // Variables para la información de la tarjeta
  final TextEditingController _holderNameController = TextEditingController();
  final TextEditingController _holderLastNameController = TextEditingController();
  final TextEditingController _holderMailController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expirationYearController = TextEditingController();
  final TextEditingController _expirationMonthController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // Llave del formulario para la validación
  final _formKey = GlobalKey<FormState>();




  final openpay = OpenpayBBVA(
    merchantId: "miozox9p5aexzx6xpqdp",
    publicApiKey: "pk_7e6fca65afc049d08052fdbdd5821652",
    productionMode: false,
    country: Country.MX,
  );

  get apiKey => null;



  @override
  void initState() {
    super.initState();
    initDeviceSession();
  }

  @override
  Widget build(BuildContext context) {
    widget.item['MetodPago'] = _selectedPayment;
    return Scaffold(
      resizeToAvoidBottomInset: true, // Esto permite ajustar el contenido cuando el teclado aparece
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0),
        child: AppBar(
          backgroundColor: whiteColor,
          title: text("Método de pago", fontSize: textSizeLarge, fontWeight: fontSemibold),
        ),
      ),
      body: LoadingOverlay(
        isLoading: isLoading,
        progressIndicator: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/progress1.gif", width: 120),
              text("¡Estamos Agendando tu cita!",
                  isCentered: true, fontWeight: fontSemibold, fontSize: textSizeLargeMedium),
            ],
          ),
        ),
        child: SingleChildScrollView( // Agregar SingleChildScrollView
          child: Container(
            padding: EdgeInsets.all(spacing_standard_new),
            child: Column(
              children: <Widget>[
                text("Selecciona uno:"),
                // Expandir la lista para que sea desplazable
                ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: paymentTypes.keys.map((String paymentMethod) {
                    return Container(
                      margin: EdgeInsets.only(bottom: spacing_standard_new),
                      decoration: BoxDecoration(
                        color: viewLineColor,
                        boxShadow: [BoxShadow(color: food_ShadowColor, blurRadius: 10, spreadRadius: 2)],
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: RadioListTile(
                        title: Text(paymentTypes[paymentMethod]['title']),
                        subtitle: Text(paymentTypes[paymentMethod]['subtitle']),
                        value: paymentMethod,
                        secondary: paymentTypes[paymentMethod]['secondary'],
                        activeColor: pantoneThirteen,
                        groupValue: _selectedPayment,
                        controlAffinity: ListTileControlAffinity.trailing,
                        onChanged: (value) {
                          setState(() {
                            _selectedPayment = value.toString();
                            widget.item['MetodPago'] = _selectedPayment;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                if (_selectedPayment == 'online') _buildCardForm(),
                Container(
                  height: 80,
                  decoration: boxDecoration(showShadow: true, radius: 0, bgColor: food_white),
                  padding: EdgeInsets.all(spacing_standard_new),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          // Primero validamos el formulario
                          if (_formKey.currentState!.validate()) {
                            // Si la validación es exitosa, activamos el estado de carga
                            setState(() {
                              isLoading = true;
                            });

                            // Dependiendo del método de pago, actuamos
                            if (widget.item['MetodPago'] != "online") {
                              // Llamamos a createRecord si el método de pago no es "online"
                              try {
                                await userPhysio.createRecord(widget.item);
                                Fluttertoast.showToast(msg: "Sesiones agendadas correctamente");

                                // Luego de crear la sesión, navegamos
                                Navigator.pushNamedAndRemoveUntil(
                                    context, HomeView.routeName, (route) => false, arguments: "2");
                              } catch (error) {
                                // En caso de error, manejamos el error aquí
                                Fluttertoast.showToast(msg: "Error al agendar sesión");
                              } finally {
                                // Al finalizar la acción, desactivamos el estado de carga
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            } else {
                              // Si el método de pago es "online", iniciamos el pago
                              try {
                                Fluttertoast.showToast(msg: "Formulario válido, procesando...");
                                await makePayment(); // Suponiendo que makePayment también es asíncrono
                              } catch (error) {
                                // En caso de error durante el proceso de pago
                                Fluttertoast.showToast(msg: "Error al procesar el pago");
                              } finally {
                                // Desactivamos el estado de carga después de completar el pago
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          } else {
                            // Si el formulario no es válido, mostramos un mensaje
                            Fluttertoast.showToast(msg: "Por favor, complete todos los campos.");
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(spacing_large, spacing_middle, spacing_large, spacing_middle),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: pantoneThirteen,
                          ),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Confirmar Paquete",
                                  style: TextStyle(fontSize: textSizeMedium, color: food_white, fontWeight: fontSemibold),
                                ),
                                WidgetSpan(
                                  child: Padding(
                                      padding: const EdgeInsets.only(left: spacing_standard),
                                      child: Icon(Icons.arrow_forward, color: food_white, size: 18)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            CreditCardWidget(
              cardBgColor: Colors.black,
              isHolderNameVisible: false,
              cardNumber: _cardNumberController.text,
              expiryDate: '${_expirationMonthController.text}/${_expirationYearController.text}',
              cardHolderName: _holderNameController.text,
              cvvCode: _cvvController.text,
              showBackView: false, // Set to true if you want to show CVV input field
              obscureCardCvv: true, // Hide CVV code in the UI
              obscureCardNumber: false, // Hide card number in the UI
              onCreditCardWidgetChange: (CreditCardBrand) {
                // Handle the card brand change if needed
              },
            ),
            SizedBox(height: 16.0),

            // Cardholder Name Input
            TextFormField(
              controller: _holderNameController,
              decoration: InputDecoration(
                labelText: 'Nombre del titular',
                border: OutlineInputBorder(),
                hintText: 'Ingresa el nombre del titular',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el nombre del titular';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),

            // Cardholder Last Name Input
            TextFormField(
              controller: _holderLastNameController,
              decoration: InputDecoration(
                labelText: 'Apellidos titular',
                border: OutlineInputBorder(),
                hintText: 'Ingresa los apellidos del titular',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa los apellidos del titular';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),

            // Cardholder Email Input
            TextFormField(
              controller: _holderMailController,
              decoration: InputDecoration(
                labelText: 'Correo del titular',
                border: OutlineInputBorder(),
                hintText: 'Ingresa el correo del titular',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el correo del titular';
                }
                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                  return 'Por favor ingresa un correo válido';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),

            // Card Number Input
            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Número de Tarjeta',
                border: OutlineInputBorder(),
                hintText: 'Ingresa número de tarjeta',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el número de tarjeta';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),

            // Expiry Date Row with MM and YY inputs
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _expirationMonthController,
                    decoration: InputDecoration(
                      labelText: 'MM',
                      border: OutlineInputBorder(),
                      hintText: 'MM',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el mes';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextFormField(
                    controller: _expirationYearController,
                    decoration: InputDecoration(
                      labelText: 'YY',
                      border: OutlineInputBorder(),
                      hintText: 'YY',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el año';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),

            // CVV Input
            TextFormField(
              controller: _cvvController,
              decoration: InputDecoration(
                labelText: 'CVV',
                border: OutlineInputBorder(),
                hintText: 'Ingresa CVV',
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el CVV';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),


          ],
        ),
      ),
    );
  }





  Future<void> makePayment() async {
    try {
      String cardNumber = _cardNumberController.text;
      String holderName = _holderNameController.text;
      String expirationYear = _expirationYearController.text;
      String expirationMonth = _expirationMonthController.text;
      String cvv2 = _cvvController.text;

      // Call createOpenPayToken to get the token
      String _token = await createOpenPayToken(
        cardNumber: cardNumber,
        holderName: holderName,
        expirationYear: expirationYear,
        expirationMonth: expirationMonth,
        cvv2: cvv2,
      );





      var charge = await createOpenPayCharge(_token);

      if (charge['status'] == 'completed') {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 100.0),
                SizedBox(height: 10.0),
                Text("¡Pago realizado correctamente!"),
              ],
            ),
          ),
        );
        userPhysio.createRecord(widget.item).then((sesion) {
          Fluttertoast.showToast(msg: "Sesiones agendadas correctamente");
        });
        Navigator.pushNamedAndRemoveUntil(
          context, HomeView.routeName, (route) => false, arguments: "2",
        );
      }
      isLoading =false;
    } catch (err) {
      isLoading =false;
      print('Error: $err');
      Fluttertoast.showToast(msg: "Error procesando el pago,Valida tus datos");
    }
  }

  Future<Map<String, dynamic>> createOpenPayCharge(String cardToken) async {
    try {

      Map<String, dynamic> customer = {
        "name": _holderNameController.text.toString(), // Replace with the actual customer's name
        "last_name": _holderLastNameController.text.toString(), // Replace with actual last name
        "phone_number": "", // no se ocupa por eso se manda vacio
        "email": _holderMailController.text.toString() // Replace with actual email
      };


      var response = await http.post(
        Uri.parse('https://sandbox-api.openpay.mx/v1/miozox9p5aexzx6xpqdp/charges'),
        headers: {
          'Authorization': 'Basic c2tfYjQwMzJlMzBjMDA4NDRmZDk1ZWU0ODUxMjVmMzE4M2E6',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'method': 'card',
          'source_id': cardToken,
          'amount': widget.item['item']['price'].toString(), // Cambia el monto según corresponda
          'currency': 'MXN',
          'device_session_id' : 'kR1MiQhz2otdIuUlQkbEyitIqVMiI16f',
          'description': widget.item['item']['name'].toString() +',Sesiones:'+ widget.item['item']['sesion'].toString(),
          'customer': customer, // Include the customer data in the body
        }),
      );
      // Check the response status
      if (response.statusCode == 200) {

         return json.decode(response.body);
      } else {
        // If the request fails, throw an exception
        throw Exception('Failed to create OpenPay token: ${response.body}');
      }


    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Future<void> initDeviceSession() async {
    String deviceID;
    try {
      deviceID =
          await openpay.getDeviceID() ?? 'Error getting the device session id';
    } catch (e) {
      rethrow;
    }

    setState(() {
    //  _deviceID = deviceID;
    });
  }

  Future<String> createOpenPayToken({
    required String cardNumber,
    required String holderName,
    required String expirationYear,
    required String expirationMonth,
    required String cvv2
  //  required Map<String, String> address

  }) async {
    // API endpoint for creating the token
    final url = 'https://sandbox-api.openpay.mx/v1/miozox9p5aexzx6xpqdp/tokens';

    // Construct the request body
    final Map<String, dynamic> requestBody = {
      'card_number': cardNumber,
      'holder_name': holderName,
      'expiration_year': expirationYear,
      'expiration_month': expirationMonth,
      'cvv2': cvv2,
     // 'address': address,
    };

    // Make the HTTP request
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic c2tfYjQwMzJlMzBjMDA4NDRmZDk1ZWU0ODUxMjVmMzE4M2E6',  // Your private API key
        },
        body: json.encode(requestBody),
      );

      // Check the response status
      if (response.statusCode == 201) {
        // If the request is successful, return the response body as a Map
        final tokenData = json.decode(response.body);
        return tokenData['id']; // Return only the token ID
       // return json.decode(response.body);
      } else {
        // If the request fails, throw an exception
        throw Exception('Failed to create OpenPay token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating token: $e');
    }
  }
}
