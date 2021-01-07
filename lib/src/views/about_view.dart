import 'package:flutter/material.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  static const routeName = 'about';

  const AboutPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColorPrimary,
        title: text('Acerca de', textColor: whiteColor),
        shadowColor: whiteColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: (MediaQuery.of(context).size.height - (kToolbarHeight * 2)),
          child: SafeArea(
              child: Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                color: whiteColor,
                padding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 34.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 100.0,
                      child: ClipRRect(
                          borderRadius:
                              BorderRadius.all(Radius.circular(spacing_middle)),
                          child: Image.asset("assets/images/hermez_icon.png")),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    text("Hermez Delivery App", fontWeight: fontBold),
                    text("v1.0.5")
                  ],
                ),
              ),
              Divider(),
              ListTile(
                onTap: () {
                  launch("https://web.yerli.app/legal/privacidad");
                },
                title: text("Política de privacidad"),
                trailing: Icon(Icons.keyboard_arrow_right),
              ),
              Divider(),
              ListTile(
                onTap: () {
                  launch("https://web.yerli.app/legal/terminos");
                },
                title: text("Términos y condiciones"),
                trailing: Icon(Icons.keyboard_arrow_right),
              ),
              Divider(),
              Expanded(child: Container()),
              text("Hermez © 2020", fontSize: textSizeSMedium),
              SizedBox(
                height: spacing_standard,
              ),
              text("Powered by:", fontSize: textSizeSmall),
              text("Statika Digital",
                  fontWeight: fontBold, fontSize: textSizeSMedium),
            ],
          )),
        ),
      ),
    );
  }
}
