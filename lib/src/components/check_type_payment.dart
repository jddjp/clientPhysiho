

import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/providers/request_repository.dart';
import 'package:clientPhysiho/src/providers/sessions_provider.dart';
import 'package:clientPhysiho/src/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class CheckTypePayment extends StatefulWidget {
  // Route name for this view
  static const routeName = 'paymentType';

  final Map<String, dynamic> item;


  CheckTypePayment({Key? key, Map<String, dynamic>? item})
      : item = item ?? <String, dynamic>{},
        super(key: key);
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
      'subtitle': 'Con Mercado Pago',
      'secondary': Image.asset(
        "assets/images/mercadopago.png",
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

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      // platformVersion = await MercadoPagoMobileCheckout.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.item['MetodPago'] = _selectedPayment;
    // print(widget.item['service']);
    // print(widget.item['item']);
    print(widget.item['sesions']);
    print(widget.item['idPhysio']);
    // print(widget.item['hours']);
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
                  "assets/images/progress.gif",
                  width: 120,
                ),
                text("¡Estamos preparando tu paquete!",
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
                          print("Online payment");
                          _launchURL(context,widget.item);
                          setState(() {
                            isLoading = false;
                          });

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



  Future<void> _launchURL(BuildContext context, Map<String, dynamic> item) async {
    final theme = Theme.of(context);
    try {

      final preferenceId = await new MPPreferenceProvider()
          .getPreferenceId(
          widget.item['service']['name'].toString(),
          widget.item['item']['name'].toString(),
          widget.item['item']['price'].toString(),item);
      print(preferenceId);
      await launchUrl(
        Uri.parse(preferenceId),
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: titleoverimage,
            navigationBarColor: titleoverimage,
          ),
          shareState: CustomTabsShareState.on,
          urlBarHidingEnabled: true,
          showTitle: true,
          animations: CustomTabsSystemAnimations.slideIn(),
          browser: const CustomTabsBrowserConfiguration(
            prefersDefaultBrowser: false,
            fallbackCustomTabs: <String>[
              'org.mozilla.firefox',
              'com.microsoft.emmx',
            ],
          ),
        ),
        safariVCOptions: SafariViewControllerOptions(
          preferredBarTintColor: theme.primaryColor,
          preferredControlTintColor: Colors.white,
          barCollapsingEnabled: true,
          entersReaderIfAvailable: false,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      debugPrint(e.toString());
    }


  }
}
