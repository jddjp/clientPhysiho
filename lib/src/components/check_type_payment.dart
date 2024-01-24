// @dart=2.9
import 'dart:convert';

import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/providers/sessions_provider.dart';
import 'package:clientPhysiho/src/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
// import 'package:mercado_pago_mobile_checkout/mercado_pago_mobile_checkout.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CheckTypePayment extends StatefulWidget {
  // Route name for this view
  static const routeName = 'paymentType';

  final Map<String, dynamic> item;

  CheckTypePayment({Key key, this.item}) : super(key: key);

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
      )
    },
  };
  final userPhysio = new SessionProvider();

  String _selectedPayment = 'cash';

  bool isLoading = false;
  static const preferenceIdcons =
      "456490293-ad1850e9-36dd-4353-9b38-b9417ff3bf9d";
  //456490293-ea66f5b6-38ca-4db1-a432-45a3edb5e642
  //TEST-6763876082927877-042719-1c46ed47fe677e536c7d0440f007b356-456490293
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    WidgetsFlutterBinding.ensureInitialized();
    String platformVersion;
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.item['MetodPago'] = _selectedPayment;
    // print(widget.item['service']);
    // print(widget.item['item']);
    print(widget.item['sesions']);
    print(widget.item['idPhysio']);
    print(widget.item['item']['price']);
    // print(widget.item['customer']);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75.0),
        child: AppBar(
          backgroundColor: whiteColor,
          title: text("Método de pago",
              fontSize: textSizeLarge, fontWeight: fontSemibold),
        ),
      ),
      body: LoadingOverlay(
          isLoading: isLoading,
          progressIndicator: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/progress1.gif",
                  width: 120,
                ),
                text("¡Estamos Agendando tu cita!",
                    isCentered: true,
                    fontWeight: fontSemibold,
                    fontSize: textSizeLargeMedium),
              ],
            ),
          ),
          child: Container(
            child: Column(children: <Widget>[
              text("Selecciona uno:"),
              SizedBox(height: spacing_large),
              Expanded(
                child: ListView(
                  children: paymentTypes.keys.map((String paymentMethod) {
                    return Container(
                      margin: EdgeInsets.only(bottom: spacing_standard_new),
                      decoration: BoxDecoration(
                        color: viewLineColor,
                        boxShadow: [
                          BoxShadow(
                              color: food_ShadowColor,
                              blurRadius: 10,
                              spreadRadius: 2)
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: new RadioListTile(
                        title: Text(paymentTypes[paymentMethod]['title']),
                        subtitle: Text(paymentTypes[paymentMethod]['subtitle']),
                        value: paymentMethod,
                        secondary: paymentTypes[paymentMethod]['secondary'],
                        /*const Icon(Icons.payment),*/
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
              ),
              Container(
                height: 80,
                decoration: boxDecoration(
                    showShadow: true, radius: 0, bgColor: food_white),
                padding: EdgeInsets.all(spacing_standard_new),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        if (widget.item['MetodPago'] != "online") {
                          userPhysio.createRecord(widget.item).then((sesion) {
                            Fluttertoast.showToast(
                                msg: "Sesiones agendadas correctamente");
                          });
                          // Redirect and remove all screens
                          Navigator.pushNamedAndRemoveUntil(
                              context, HomeView.routeName, (route) => false,
                              arguments: "2");
                        } else {
                          WidgetsFlutterBinding.ensureInitialized();
                          // create payment method
                          //pk_test_51Nq3fsDmZEM6EpGy6OrWjZhibMW390AyiyAe6IlIVPMN4LZs7R77WxQGyDKvukypSldXCtX8tYtzID7L6aOuHzPu00TH2t7YE4
                          //Assign publishable key to flutter_stripe

                          Stripe.publishableKey =
                              "pk_live_51Nq3fsDmZEM6EpGygH3bRZiBSDyQVU8MndbeiFZb0HDRwke24csGic52S9CjaVFeI99pWN2IwWtjkbAwtspeFF8h00FKcR2WEW";
                          // Stripe.merchantIdentifier =
                          //     "merchant.mx.com.ybooks.app";
                          await dotenv.load(fileName: "assets/.env");
                          makePayment(widget.item['item']['price']);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(spacing_large,
                            spacing_middle, spacing_large, spacing_middle),
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
                                  style: TextStyle(
                                      fontSize: textSizeMedium,
                                      color: food_white,
                                      fontWeight: fontSemibold)),
                              WidgetSpan(
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: spacing_standard),
                                    child: Icon(Icons.arrow_forward,
                                        color: food_white, size: 18)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ]),
          )),
    );
  }

  var paymentIntent;

  Future<void> makePayment(int bookPrice) async {
    try {
      //STEP 1: Create Payment Intent
      paymentIntent =
          await createPaymentIntent((bookPrice * 100).toString(), 'MXN');

      //STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret:
                paymentIntent['client_secret'], //Gotten from payment intent
            style: ThemeMode.light,
            merchantDisplayName: 'Book',
          ))
          .then((value) {});

      //STEP 3: Display Payment sheet
      displayPaymentSheet();
    } catch (err) {
      throw Exception(err);
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 100.0,
                      ),
                      SizedBox(height: 10.0),
                      Text("Pago realizado correctamente!"),
                    ],
                  ),
                ));
        userPhysio.createRecord(widget.item).then((sesion) {
          Fluttertoast.showToast(msg: "Sesiones agendadas correctamente");
        });
        // Redirect and remove all screens
        Navigator.pushNamedAndRemoveUntil(
            context, HomeView.routeName, (route) => false,
            arguments: "2");
        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text("Error procesando el pago"),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      print('$e');
    }
  }
}
