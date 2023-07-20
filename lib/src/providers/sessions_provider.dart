// @dart=2.9
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

  Future<List<Map<String, dynamic>>> getHours(
      int index, String idEmployee, String sesionsListIndex) async {
    var hoursListIndex = new List(15);
    List<Map<String, dynamic>> hoursList = new List();

    hoursList.add(
      {
        'value': '9:00',
        'label': '9:00 - 10:00',
        'icon': Icon(Icons.stop),
      },
    );
    hoursList.add(
      {
        'value': '10:30',
        'label': '10:30 - 11:30',
        'icon': Icon(Icons.stop),
      },
    );
    hoursList.add(
      {
        'value': '12:00',
        'label': '12:00 - 13:00',
        'icon': Icon(Icons.stop),
      },
    );
    hoursList.add(
      {
        'value': '13:30',
        'label': '13:30 - 14:30',
        'icon': Icon(Icons.stop),
      },
    );
    hoursList.add(
      {
        'value': '16:00',
        'label': '16:00 - 17:00',
        'icon': Icon(Icons.stop),
      },
    );
    hoursList.add(
      {
        'value': '17:30',
        'label': '17:30 - 18:30',
        'icon': Icon(Icons.stop),
      },
    );

    DocumentReference physioRef =
        FirebaseFirestore.instance.collection('users').doc(idEmployee);

    print('physio : ${physioRef}');

    if (sesionsListIndex != null) {
      QuerySnapshot sesionData = await FirebaseFirestore.instance
          .collection('sesionRecord')
          .where('users', isEqualTo: physioRef)
          .where('estatus', isEqualTo: 1)
          .where('date', isEqualTo: sesionsListIndex)
          // .orderBy('fecha')
          .get();

      print('reference physio');
      print(physioRef);
      print('reference sesions Record');
      print(sesionData);
      sesionData.docs.forEach((element) {
        print(element.data());
        Map<String, dynamic> elemnt = element.data();
        hoursList.forEach((elementHours) {
          print(elementHours);
          if (elementHours['value'] == elemnt['hours']) {
            print(
                'si se encuentra ${elementHours['value']} && ${elemnt['hours']}');
            elementHours['enable'] = false;
          }
        });
      });
      print(
          'date list : $sesionsListIndex && idEmployee : $idEmployee & index : $index');
    }

    return hoursList;
  }

  Future<List<Map<String, dynamic>>> getAllPhysih() async {
    print('userPhysio');
    Map<String, dynamic> _currentUser;
    List<Map<String, dynamic>> _employess = new List();
    /*final autoId = _getAutoId();

    print(autoId);*/

    QuerySnapshot user = await FirebaseFirestore.instance
        .collection('users')
        .where('type', isEqualTo: 'employees')
        .where('estatus', isEqualTo: 'activo')
        .get();

    user.docs.forEach((element) {
      print(element.data());
      Map<String, dynamic> elemnt = element.data();
      _employess.add({
        'value': '10:30',
        'label': elemnt["name"],
        'icon': Icon(Icons.stop),
      });
      //_employess.add(elemnt);
      //print(element);
      /*_currentUser = {
        'id': element.reference.id,
        "name": elemnt['name'],
        "photo": elemnt['profile'] != null && elemnt['profile'] != ''
            ? elemnt['profile']['url']
            : 'https://firebasestorage.googleapis.com/v0/b/fisioterapia-cfb53.appspot.com/o/profiles%2FixkZaOLGO66wyZw6.jpeg?alt=media&token=4728c68a-d291-4910-af8a-5f5a628a47e6'
      };*/
    });

    return _employess;
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
      Map<String, dynamic> elemnt = element.data();
      _currentUser = {
        'id': element.reference.id,
        "name": elemnt['name'],
        "photo": elemnt['profile'] != null && elemnt['profile'] != ''
            ? elemnt['profile']['url']
            : 'https://firebasestorage.googleapis.com/v0/b/fisioterapia-cfb53.appspot.com/o/profiles%2FixkZaOLGO66wyZw6.jpeg?alt=media&token=4728c68a-d291-4910-af8a-5f5a628a47e6'
      };
    });

    return _currentUser;
  }

  Future<List<dynamic>> getSessionUser(String id) async {
    print('userPhysio===============>' + id);

    DocumentReference customerRef =
        FirebaseFirestore.instance.collection('customers').doc(id);
    print(customerRef);

    QuerySnapshot sesionData = await FirebaseFirestore.instance
        .collection('sesionRecord')
        .where('customers', isEqualTo: customerRef)
        .get();
    List<dynamic> sesion = new List();

    var sesiones = await sesionData.docs;

    for (var element in sesiones) {
      Map<String, dynamic> elemnt = element.data();

      DocumentSnapshot record = await FirebaseFirestore.instance
          .collection('Record')
          .doc(elemnt['record'].id)
          .get();

      DocumentSnapshot service = await FirebaseFirestore.instance
          .collection('services')
          .doc((record.data() as Map<String, dynamic>)['service'].id)
          .get();
      DocumentSnapshot package = await FirebaseFirestore.instance
          .collection('items')
          .doc((record.data() as Map<String, dynamic>)['package'].id)
          .get();

      sesion.add({
        'hours': elemnt['hours'],
        'date': elemnt['date'],
        'serviceName': (service.data() as Map<String, dynamic>)['name'],
        'status': elemnt['estatus'],
        'packageName': (package.data() as Map<String, dynamic>)['name'],
      }
          //element.data()
          );
      print("yair:" + element.id);
    }

    sesion.sort((a, b) => a['date'].compareTo(b['date']));

    return sesion;
  }

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
      'users': userRef,
      'location': item['location']
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
