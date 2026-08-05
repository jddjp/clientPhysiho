
import 'package:http/http.dart' as http;
import 'dart:convert';

class StatesMProvider {
  Future<List<dynamic>> states() async {
    print('provider');

    final result = await http.get(Uri.parse(
        'https://api-sepomex.hckdrk.mx/query/get_estados?token=a2f08702-dc7c-4a49-a792-f79664589890'));

    if (result.statusCode != 200) {
      return [];
    }

    final body = utf8.decode(result.bodyBytes);
    final jsonResponse = jsonDecode(body);
    final List<dynamic> listState = [];

    for (var item in (jsonResponse['response']?['estado'] ?? [])) {
      print(item);
      listState.add(item);
    }

    return listState;
  }

  Future<List<dynamic>> municipio(String states) async {
    print('provider');
    print(states);
    final result = await http.get(
      Uri.parse(
          'https://api-sepomex.hckdrk.mx/query/get_municipio_por_estado/' +
              states +
              '?token=a2f08702-dc7c-4a49-a792-f79664589890'),
    );

    if (result.statusCode != 200) {
      return [];
    }

    final body = utf8.decode(result.bodyBytes);
    final jsonResponse = jsonDecode(body);
    final List<dynamic> listMunicipios = [];

    print(jsonResponse['response']?['municipios']);
    for (var item in (jsonResponse['response']?['municipios'] ?? [])) {
      listMunicipios.add(item);
    }

    return listMunicipios;
  }
}
