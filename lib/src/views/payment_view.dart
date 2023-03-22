// @dart=2.9
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
                  "assets/images/progress.gif",
                  width: 120,
                ),
                text("¡Estamos preparando tu pedido!",
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
}
