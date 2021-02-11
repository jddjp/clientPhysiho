import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartServiceController extends ControllerMVC {
  bool isLoading = true;
  Map<String, dynamic> service;
  Map<String, dynamic> itemService;
  SharedPreferences _idservices;

  CartServiceController(Map<String, dynamic> data) {
    initialize();
    asyncData(data);
  }

  void initialize() async {
    _idservices = await SharedPreferences.getInstance();
    print('inicializacion pref');
    print(_idservices.getString('idservicio'));
    print(_idservices.getString('idpaqueteservicio'));
  }

  void asyncData(Map<String, dynamic> item) async {
    print('asyncData');

    if (item == null) {
      item['id'] = await _idservices.getString('idpaqueteservicio');
      item['idservice'] = await _idservices.getString('idservicio');
    }
    print(item);
    DocumentReference serviceRef = FirebaseFirestore.instance
        .collection('services')
        .doc(item['idservice']);
    DocumentReference itemRef =
        FirebaseFirestore.instance.collection('items').doc(item['id']);
    DocumentSnapshot serviceDoc = await serviceRef.get();
    service = {...serviceDoc.data(), 'id': serviceDoc.id};
    DocumentSnapshot itemDoc = await itemRef.get();
    itemService = {...itemDoc.data(), 'id': itemDoc.id};
    print('itemService');
    print(itemService);
    setState(() {
      isLoading = false;
    });
  }
}
