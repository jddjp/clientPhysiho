import 'package:flutter/material.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:provider/provider.dart';

class CheckoutView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'checkout';

  @override
  _CheckoutViewState createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            text("Espera por favor...",
                maxLine: null, isCentered: true, textColor: textSecondaryColor)
          ],
        ),
      ),
    );
  }
}
