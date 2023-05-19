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
    print(_getAutoId());

    final autoId = _getAutoId();

    QuerySnapshot user = await FirebaseFirestore.instance
        .collection('users')
        .where('type', isEqualTo: 'employees')
        .where('estatus', isEqualTo: 'activo')
        .get();

    final random = new Random();

    var element = user.docs[random.nextInt(user.docs.length)];

    print("Yair lenght: "+user.docs.length.toString());
    print("Yair random: " + element.id);

    Map<String, dynamic> el = element.data() as Map<String, dynamic>;
    print("Yair: " + el['profile'].toString());
    employee = {
      'id': element.reference.id,
      "name": el['name'],
      "photo": el['profile'] != null && el['profile'] != ''
          ? el['profile']['url']
          : 'https://firebasestorage.googleapis.com/v0/b/fisioterapia-cfb53.appspot.com/o/profiles%2FBoEoSxoQyyLZdGbu.png?alt=media&token=39837240-bcca-4724-a843-d9fbf96b9456'
    };

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
}
