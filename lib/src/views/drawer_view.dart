import 'package:flutter/material.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/providers/login_provider.dart';
import 'package:clientPhysiho/src/views/about_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerView extends StatelessWidget {
  static const routeName = 'drawer';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          DrawerHeader(
            margin: EdgeInsets.only(top: 49),
            child: Container(),
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/Physioh1shadow.png'),
              fit: BoxFit.contain,
            )),
          ),
          ListTile(
            title: Text('Soporte'),
            leading: Icon(Icons.help_outline, color: appColorPrimary),
            onTap: () {
              Uri waUrl = Uri(
                  scheme: "https",
                  host: "wa.me",
                  path: "522482409614",
                  queryParameters: {
                    "text": "Hola, ¿Estoy contactando con el soporte de Hermez?"
                  });
              launch(waUrl.toString());
            },
          ),
          ListTile(
            title: Text('Acerca de'),
            leading: Icon(Icons.account_circle, color: appColorPrimary),
            //launchScreen(context, AboutPage.routeName),
            onTap: () => Navigator.pushNamed(context, 'about'),
          ),
          ListTile(
            title: Text('Cerrar sesión'),
            leading: Icon(Icons.subdirectory_arrow_left_rounded,
                color: appColorPrimary),
            onTap: () {
              Provider.of<LoginProvider>(context, listen: false).logout();
              //launchScreen(context, LoginView.routeName);
            },
          ),
        ],
      ),
    );
  }
}
