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
}
