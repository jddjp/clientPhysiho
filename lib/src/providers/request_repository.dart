// @dart=2.9
import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestProvider {
  Future<String> getPreferenceId(
      String title, String description, String price) async {
    print('MP preference provider');

    final result = await http.post(
      Uri.parse(
          'https://us-central1-fisioterapia-cfb53.cloudfunctions.net/getPreferenceIdMP'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'description': description,
        'price': price,
      }),
    );

    List<int> bytes = result.bodyBytes;
    if (result.statusCode == 200) {
      var body = utf8.decode(bytes);
      var jsonResponse = jsonDecode(body);

      print("id: "+jsonResponse['id']);
      print("status: "+jsonResponse['status']);
    }
    return "OK";
  }
}
