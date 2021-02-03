import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StatesMProvider {
  Future<List<dynamic>> states() async {
    print('provider');

    final result = await http.get(
      'https://api-sepomex.hckdrk.mx/query/get_estados',
    );
    List<int> bytes = result.bodyBytes;
    if (result.statusCode == 200) {
      var body = utf8.decode(bytes);
      var jsonResponse = jsonDecode(body);

      //print(jsonResponse['response']['estado']);

      List<dynamic> listState = new List();

      for (var item in jsonResponse['response']['estado']) {
        //print(item);
        listState.add(item);
      }

      return listState;
    }
  }

  Future<List<dynamic>> municipio(String states) async {
    print('provider');
    print(states);
    final result = await http.get(
      'https://api-sepomex.hckdrk.mx/query/get_municipio_por_estado/' + states,
    );
    List<int> bytes = result.bodyBytes;
    if (result.statusCode == 200) {
      var body = utf8.decode(bytes);
      var jsonResponse = jsonDecode(body);

      print(jsonResponse['response']['municipios']);

      List<dynamic> listMunicipios = new List();
      for (var item in jsonResponse['response']['municipios']) {
        listMunicipios.add(item);
      }

      return listMunicipios;
    }
  }
}
