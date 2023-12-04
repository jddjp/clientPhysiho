
import 'package:clippy_flutter/arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:clientPhysiho/src/components/default_button.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/config/images.dart';
import 'package:clientPhysiho/src/config/strings.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/providers/login_provider.dart';
import 'package:clientPhysiho/src/views/complete_profile_view.dart';
import 'package:clientPhysiho/src/views/create_account_view.dart';
import 'package:clientPhysiho/src/views/home_services_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class LoginView extends StatefulWidget {
  static const routeName = 'login';

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    changeStatusColor(pantoneTwo);
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    Widget socialButton(var color, var icon, var value, var iconColor,
        var valueColor, VoidCallback onPressed) {
      return SizedBox(
        width: double.infinity,
        height: 50.0,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            primary: color,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
          ),
          onPressed: onPressed,
          icon: SvgPicture.asset(icon, color: iconColor, width: 18, height: 18),
          label: Text(
            value,
            style: TextStyle(fontSize: textSizeMedium, color: valueColor),
          ),
        ),
      );
    }

    return Scaffold(
      body: LoadingOverlay(
        isLoading: Provider.of<LoginProvider>(context).isLoading(),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: const Color(0xff7c94b6),
                backgroundBlendMode: BlendMode.color,
                image: DecorationImage(
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.9), BlendMode.dstATop),
                    image: new AssetImage('assets/images/IMAPH.png'),
                    fit: BoxFit.fill),
              ),
            ),
            Container(
              height: width * 0.7,
              width: width,
              padding: EdgeInsets.only(top: 90, bottom: 0),
              child: Center(
                child: Image.asset("assets/images/physiohLogin.png"),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: height / 2),
              child: Stack(
                children: <Widget>[
                  Arc(
                    arcType: ArcType.CONVEX,
                    edge: Edge.TOP,
                    height: (MediaQuery.of(context).size.width) / 10,
                    child: new Container(
                        height: (MediaQuery.of(context).size.height),
                        width: MediaQuery.of(context).size.width,
                        color: pantoneTwo),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: food_color_green),
                      width: width * 0.13,
                      height: width * 0.13,
                      child: Icon(Icons.arrow_forward, color: whiteColor),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.all(spacing_standard_new),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: width * 0.1),
                        text("Bienvenido",
                            textColor: whiteColor,
                            fontWeight: fontBold,
                            fontSize: textSizeXLarge),
                        SizedBox(height: width * 0.05),
                        socialButton(
                            whiteColor,
                            food_ic_google_fill,
                            "Ingresar con Google",
                            googleColor,
                            textPrimaryColor, () {
                          Provider.of<LoginProvider>(context, listen: false)
                              .login("google")
                              .then((value) {
                            launchScreen(
                                context, CompleteProfileView.routeName);
                          });
                        }),

                        /*SizedBox(height: width * 0.05),
                        socialButton(
                            facebookColor,
                            food_ic_fb,
                            "Ingresar con Facebook",
                            whiteColor,
                            whiteColor, () {
                          Provider.of<LoginProvider>(context, listen: false)
                              .login("facebook")
                              .then((value) {
                            launchScreen(
                                context, CompleteProfileView.routeName);
                          });
                          /*Provider.of<LoginProvider>(context, listen: false)
                              .loginFacebook();*/
                        }),*/

                        SizedBox(height: width * 0.05),
                        DefaultButton(
                          text: "Usar número de teléfono",
                          press: () {
                            launchScreen(context, CreateAccountView.routeName);
                          },
                        ),
                        Platform.isIOS
                            ? SizedBox(height: width * 0.05)
                            : Container(),
                        Platform.isIOS
                            ? socialButton(
                                whiteColor,
                                food_ic_apple,
                                "Iniciar sesión con Apple",
                            appleColor,
                                textPrimaryColor, () {
                                Provider.of<LoginProvider>(context,
                                        listen: false)
                                    .login("apple")
                                    .then((value) {
                                                 Fluttertoast.showToast(
                                msg: "Accedio correctamente");
                                  launchScreen(
                                      context, HomeServiceView.routeName);
                                });
                              })  
                            : Container()
                        
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
