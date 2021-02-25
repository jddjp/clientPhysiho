import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionProvider {
  Future<Map<String, dynamic>> getPhysio(DateTime sesionInit) async {
    print('userPhysio');
    print(sesionInit);

    QuerySnapshot user = await FirebaseFirestore.instance
        .collection('users')
        .where('type', isEqualTo: 'employees')
        .get();

    QuerySnapshot sesionData =
        await FirebaseFirestore.instance.collection('sesionRecord').get();

    sesionData.docs.forEach((element) {
      print(element.data());
    });

    user.docs.forEach((element) {
      print(element.data()['name']);
    });
  }

  Future<Map<String, dynamic>> getHoursSession() async {}

  Future<List<dynamic>> getSessionUser(String id) async {
    print('userPhysio');
    DocumentReference customerRef =
        FirebaseFirestore.instance.collection('customers').doc(id);

    QuerySnapshot sesionData = await FirebaseFirestore.instance
        .collection('sesionRecord')
        .where('customers', isEqualTo: customerRef)
        // .orderBy('fecha')
        .get();
    List<dynamic> sesion = new List();
    print(sesionData);
    sesionData.docs.forEach((element) {
      sesion.add(element.data());
      print(element.data());
    });
    print("hola prueba");

    print(sesion);

    // sesionData.docs.forEach((element) {
    //   print(element.data());
    //   print("hola element . data");
    // });

    return sesion;
  }
}
