// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class CartServiceController extends ControllerMVC {
  bool isLoading = true;
  Map<String, dynamic> service;
  Map<String, dynamic> itemService;
  Map<String, dynamic> employee;
  SharedPreferences _idservices;
  List<Map<String, dynamic>> employess = [];
  String selectedLocation; // Propiedad para la ubicación seleccionada

  CartServiceController(Map<String, dynamic> data) {
    initialize();
    asyncData(data);
  }

  void initialize() async {
    _idservices = await SharedPreferences.getInstance();
    // print('inicializacion pref');
    // print(_idservices.getString('idservicio'));
    // print(_idservices.getString('idpaqueteservicio'));
  }

  void asyncData(Map<String, dynamic> item) async {
    print('asyncData');

    if (item == null) {
      item['id'] = await _idservices.getString('idpaqueteservicio');
      item['idservice'] = await _idservices.getString('idservicio');
    }

    print('selectedLocation');
    print(selectedLocation);

    // QuerySnapshot user = await FirebaseFirestore.instance
    //     .collection('users')
    //     .where('type', isEqualTo: 'employees')
    //     .where('estatus', isEqualTo: 'activo')
    //     //     .where('consulta', whereIn: [
    //     //   selectedLocation,
    //     //   'ambos'
    //     // ]) // Filtra por "Domicilio" y "ambos" // Filtro por ubicación
    //     //  .where('consulta', isEqualTo: 'activo')
    //     .get();

    // user.docs.forEach((element) {
    //   Map<String, dynamic> newElement = element.data() as Map<String, dynamic>;
    //   employess.add({'id': element.reference.id, 'name': newElement['name']});
    //   print("YAIR");
    //   print(element.data());
    // });

    // final random = new Random();

    // var element = user.docs[random.nextInt(user.docs.length)];

    // Map<String, dynamic> el = element.data() as Map<String, dynamic>;
    // // print("Yair: " + el['profile'].toString());
    // employee = {
    //   'id': element.reference.id,
    //   "name": el['name'],
    //   "photo": el['profile'] != null && el['profile'] != ''
    //       ? el['profile']['url']
    //       : 'https://firebasestorage.googleapis.com/v0/b/fisioterapia-cfb53.appspot.com/o/profiles%2FBoEoSxoQyyLZdGbu.png?alt=media&token=39837240-bcca-4724-a843-d9fbf96b9456'
    // };

    DocumentReference serviceRef = FirebaseFirestore.instance
        .collection('services')
        .doc(item['idservice']);
    DocumentReference itemRef =
        FirebaseFirestore.instance.collection('items').doc(item['id']);
    DocumentSnapshot serviceDoc = await serviceRef.get();
    service = {
      ...serviceDoc.data() as Map<String, dynamic>,
      'id': serviceDoc.id
    };
    DocumentSnapshot itemDoc = await itemRef.get();
    itemService = {...itemDoc.data() as Map<String, dynamic>, 'id': itemDoc.id};
    print('itemService');
    print(itemService);
    setState(() {
      isLoading = false;
    });
  }

  void asyncDataEmployes(String ubi) async {
    print('asyncDataEmployes=>>>>>>>>>>>');
    print(service['ubicacion']);
    print(ubi);

    //try {
    // Limpiar la lista de empleados antes de llenarla
    // employess.clear();
    employess.clear();
    QuerySnapshot user = await FirebaseFirestore.instance
        .collection('users')
        .where('type', isEqualTo: 'employees')
        .where('estatus', isEqualTo: 'activo')
        .where('consulta', isEqualTo: ubi)
        .get();

    user.docs.forEach((element) {
      Map<String, dynamic> newElement = element.data() as Map<String, dynamic>;
      employess.add({'id': element.reference.id, 'name': newElement['name']});
      //print("YAIR");
      //  print(employess);
    });
    setState(() {});
    print("employess=============>");
    print(employess);
  }
}
