import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class BusinessController extends ControllerMVC {
  bool isLoading = true;
  Map<String, dynamic> business;
  List<QueryDocumentSnapshot> sections;
  Map<String, List> items;

  BusinessController(String businessId) {
    asyncData(businessId);
  }

  void asyncData(String businessId) async {
    DocumentReference businessRef =
        FirebaseFirestore.instance.collection('services').doc(businessId);

    // Load business data
    DocumentSnapshot businessDoc = await businessRef.get();
    business = {...businessDoc.data(), "id": businessDoc.id};

    setState(() {
      business = businessDoc.data();
      isLoading = false;
    });
  }
}
