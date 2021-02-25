import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SessionProvider {
  static const AUTO_ID_ALPHABET =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  static const AUTO_ID_LENGTH = 20;
  String _getAutoId() {
    final buffer = StringBuffer();
    final random = Random.secure();

    final maxRandom = AUTO_ID_ALPHABET.length;

    for (int i = 0; i < AUTO_ID_LENGTH; i++) {
      buffer.write(AUTO_ID_ALPHABET[random.nextInt(maxRandom)]);
    }
    return buffer.toString();
  }

  Future<Map<String, dynamic>> getPhysio() async {
    print('userPhysio');
    Map<String, dynamic> _currentUser;
    final autoId = _getAutoId();

    print(autoId);

    QuerySnapshot user = await FirebaseFirestore.instance
        .collection('users')
        .where('type', isEqualTo: 'employees')
        .where('estatus', isEqualTo: 'activo')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: autoId)
        .limit(1)
        .get();
    user.docs.forEach((element) {
      print(element.data());
      _currentUser = {
        'id': element.reference.id,
        "name": element.data()['name'],
        "photo": element.data()['profile'] != null ||
                element.data()['profile'] != ''
            ? element.data()['profile']['url']
            : 'https://firebasestorage.googleapis.com/v0/b/fisioterapia-cfb53.appspot.com/o/profiles%2FixkZaOLGO66wyZw6.jpeg?alt=media&token=4728c68a-d291-4910-af8a-5f5a628a47e6'
      };
    });

    return _currentUser;
  }

  Future<Map<String, dynamic>> getHoursSession() async {}

  Future<DocumentReference> createRecord(Map<String, dynamic> item) async {
    print('create session');
    print(item['item']['sesion']);
    item.forEach((key, value) {
      print(value);
      print(key);
    });
    var pago = item['MetodPago'] == 'cash' ? 1 : 2;

    print(pago);

    CollectionReference record =
        FirebaseFirestore.instance.collection('Record');
    CollectionReference sesionRecord =
        FirebaseFirestore.instance.collection('sesionRecord');

    DocumentReference customerRef = FirebaseFirestore.instance
        .collection('customers')
        .doc(item['customer']);
    DocumentReference serviceRef = FirebaseFirestore.instance
        .collection('services')
        .doc(item['service']['id']);
    DocumentReference itemRef =
        FirebaseFirestore.instance.collection('items').doc(item['item']['id']);
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(item['idPhysio']);

    print(customerRef);

    DocumentReference recordAdd = await record.add({
      'costo': item['item']['price'],
      'customers': customerRef,
      'estatus': 1,
      'estatuspago': 2,
      'metodoPago': pago,
      'fecha': DateTime.now(),
      'service': serviceRef,
      'package': itemRef,
      'users': userRef
    });

    print(recordAdd.get());

    if (recordAdd.id.isNotEmpty) {
      print('added record');
      for (var i = 0; i < item['item']['sesion']; i++) {
        print(item['sesions'][i]);
        print(item['hours'][i]);
        await sesionRecord.add({
          'comment': '',
          'fecha': DateFormat('yyyy-MM-dd HH:mm')
              .parse(item['sesions'][i] + ' ' + item['hours'][i]),
          'customers': customerRef,
          'date': item['sesions'][i],
          'hours': item['hours'][i],
          'record': recordAdd,
          'users': userRef,
          'estatus': 1
        });
      }
    }
    return Future.value(recordAdd);
  }
}
