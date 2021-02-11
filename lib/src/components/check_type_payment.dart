import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    print(widget.item['service']);
    print(widget.item['item']);
    print(widget.item['sesions']);
    return Container(
      child: Text('Payment type '),
    );
  }
}
