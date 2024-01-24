// @dart=2.9
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/providers/cart_provider.dart';
import 'package:clientPhysiho/src/views/checkout_view.dart';
import 'package:clientPhysiho/src/views/tracking_view.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
//Stripe
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'payment';

  @override
  _PaymentViewState createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  Map<String, dynamic> paymentTypes = {
    'cash': {
      'title': 'Pago en efectivo',
      'subtitle': 'Al recibir tu pedido',
      'secondary': Image.asset("assets/images/pago.png")
    },
    'clip': {
      'title': 'Pago con tarjeta',
      'subtitle': 'Con Clip al recibir tu pedido',
      'secondary': Image.asset(
        "assets/images/clip.png",
        width: 55,
        height: 40,
      )
    },
    /*'online': {
      'title': 'Pago con tarjeta',
      'subtitle': 'Paga en línea'
    },*/
  };

  String _selectedPayment = 'cash';
  bool isLoading = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    changeStatusColor(whiteColor);
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
                        activeColor: appColorAccent,
                        groupValue: _selectedPayment,
                        controlAffinity: ListTileControlAffinity.trailing,
                        onChanged: (String value) {
                          setState(() {
                            if (value == "clip") {
                              // create payment method
                              //Assign publishable key to flutter_stripe
                              Stripe.publishableKey =
                                  "pk_live_51JXz00JYJAHy112kNKOw3UoEv27GWpVBWPbUmXdULWfzsb5ieyZt55RTQkAEh7I6lWDzm41KRWkCoYOIWjq5DAHd00fxs8h2cj";
                              Stripe.merchantIdentifier =
                                  "merchant.mx.com.ybooks.app";
                                  print(context.watch<CartProvider>().orderTotal().toStringAsFixed(0));
                              makePayment(200);
                            }

                            context.read<CartProvider>().order.paymentMethod =
                                value;
                            _selectedPayment = value;
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        text(
                            "Total: \$${context.watch<CartProvider>().orderTotal().toStringAsFixed(0)}",
                            fontSize: textSizeLargeMedium,
                            fontWeight: fontSemibold),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isLoading = true;
                        });

                        // Create order
                        Provider.of<CartProvider>(context, listen: false)
                            .createOrder(context)
                            .then((order) {
                          setState(() {
                            isLoading = false;
                          });
                          // Redirect and remove all screens
                          Navigator.pushNamedAndRemoveUntil(
                              context, TrackingView.routeName, (route) => false,
                              arguments: order.id);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(spacing_large,
                            spacing_middle, spacing_large, spacing_middle),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: appColorAccent,
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: "Confirmar pedido",
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
      //showErrorSnackBar('Error al realizar el pago: ' + err.toString());
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
          'Authorization':
              'Bearer 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',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      // showErrorSnackBar('Error al realizar el pago: ' + err.toString());
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        // this.onApprove(context, "testTransaction");
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
