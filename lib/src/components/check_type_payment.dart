import 'dart:convert';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/providers/sessions_provider.dart';
import 'package:clientPhysiho/src/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openpay_bbva/openpay_bbva.dart';  // Asegúrate de importar openpay_bbva

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
      )
    },
  };

  final userPhysio = SessionProvider();
  String _selectedPayment = 'cash';
  bool isLoading = false;

  // Variables para la información de la tarjeta
  final TextEditingController _holderNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expirationYearController = TextEditingController();
  final TextEditingController _expirationMonthController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  String _deviceID = '';
  String _token = '';
  final openpay = OpenpayBBVA(
    merchantId: "mliwbrm4orj40lhks7kv",
    publicApiKey: "pk_ae8ecf5728684d22b5975cb2a966fdfe",
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75.0),
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
        child: Container(
          child: Column(
            children: <Widget>[
              text("Selecciona uno:"),
              SizedBox(height: spacing_large),
              Expanded(
                child: ListView(
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
                        setState(() {
                          isLoading = true;
                        });
                        if (widget.item['MetodPago'] != "online") {
                          userPhysio.createRecord(widget.item).then((sesion) {
                            Fluttertoast.showToast(msg: "Sesiones agendadas correctamente");
                          });
                          Navigator.pushNamedAndRemoveUntil(
                              context, HomeView.routeName, (route) => false, arguments: "2");
                        } else {
                          WidgetsFlutterBinding.ensureInitialized();
                          await dotenv.load(fileName: "assets/.env");
                          makePayment(_token);
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
                                  style: TextStyle(
                                      fontSize: textSizeMedium, color: food_white, fontWeight: fontSemibold)),
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
    );
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(spacing_standard_new),
          child: TextField(
            controller: _holderNameController,
            decoration: InputDecoration(labelText: "Nombre en la tarjeta"),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(spacing_standard_new),
          child: TextField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Número de tarjeta"),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(spacing_standard_new),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expirationMonthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Mes de expiración"),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _expirationYearController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Año de expiración"),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(spacing_standard_new),
          child: TextField(
            controller: _cvvController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "CVV"),
          ),
        ),
      ],
    );
  }

  Future<void> makePayment(String cardToken) async {
    try {
      var charge = await createOpenPayCharge(cardToken);

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
    } catch (err) {
      print('Error: $err');
      Fluttertoast.showToast(msg: "Error procesando el pago");
    }
  }

  Future<Map<String, dynamic>> createOpenPayCharge(String cardToken) async {
    try {
      var response = await http.post(
        Uri.parse('https://api.openpay.mx/v1/your_openpay_merchant_id/charges'),
        headers: {
          'Authorization': 'Bearer your_openpay_private_key',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'method': 'card',
          'source_id': cardToken,
          'amount': '1000', // Cambia el monto según corresponda
          'currency': 'MXN',
          'description': 'Compra de servicio',
          'device_session_id': 'device_session_id_example'
        }),
      );
      return json.decode(response.body);
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
      _deviceID = deviceID;
    });
  }
}
