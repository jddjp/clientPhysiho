import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_view.dart';
import 'package:clientPhysiho/src/providers/sessions_provider.dart';  // Importa tu provider aquí

class CheckoutView extends StatefulWidget {
  static const routeName = 'checkout';

  @override
  _CheckoutViewState createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  Map<String, dynamic>? item;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadItemFromPrefs());
  }


  Future<void> _loadItemFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final itemJson = prefs.getString('compraPendiente');
    if (itemJson != null) {
      setState(() {
        item = jsonDecode(itemJson);
      });
      print('Item recuperado: $item');

      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      sessionProvider.createRecord(item!).then((sesion) {
        Fluttertoast.showToast(msg: "Sesiones agendadas correctamente");

        prefs.remove('compraPendiente');

        Navigator.pushNamedAndRemoveUntil(
          context,
          HomeView.routeName,
              (route) => false,
          arguments: "2",
        );
      });
    }
  }

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
            text(
              "¡Estamos Agendando tu cita!",
              isCentered: true,
              fontWeight: fontSemibold,
              fontSize: textSizeLargeMedium,
            ),
            text(
              "Espera por favor...",
              maxLine: null,
              isCentered: true,
              textColor: textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
