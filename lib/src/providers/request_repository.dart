
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MPPreferenceProvider {
  Future<String> getPreferenceId(
      String title, String description, String price, Map<String, dynamic> item) async {
    print('MP preference provider');
    final prefs = await SharedPreferences.getInstance();

    final serializableItem = makeJsonSerializable(item);
    final itemJson = jsonEncode(serializableItem);
    await prefs.setString('compraPendiente', itemJson);


    final result = await http.post(
      Uri.parse(
          'https://us-central1-fisioterapia-cfb53.cloudfunctions.net/getPreferenceIdMP'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'description': description,
        'price': price
      }),
    );
    print("Producto:");
    print(title);
    print(description);
    print(price);
    List<int> bytes = result.bodyBytes;
    if (result.statusCode == 200) {
      var body = utf8.decode(bytes);
      var jsonResponse = jsonDecode(body);


      return jsonResponse['init_point'];
    }
    return "OK";
  }

  dynamic makeJsonSerializable(dynamic value) {
    if (value is DocumentReference) {
      return value.path; // Convertimos a string
    } else if (value is DateTime) {
      return value.toIso8601String(); // Convertimos a string
    } else if (value is Map) {
      return value.map((key, val) => MapEntry(key, makeJsonSerializable(val)));
    } else if (value is List) {
      return value.map(makeJsonSerializable).toList();
    }
    return value; // De lo contrario, retornamos el valor como está
  }
}
