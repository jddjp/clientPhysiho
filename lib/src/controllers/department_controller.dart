import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class DepartmentController extends ControllerMVC {
  bool isLoading = true;
  Map<String, dynamic> department;
  List<QueryDocumentSnapshot> categories;
  List<QueryDocumentSnapshot> businesses;

  DepartmentController(String docId) {
    print("============================");
    asyncData(docId);
  }

  void asyncData(String docId) async {
    DocumentReference departmentRef =
        FirebaseFirestore.instance.collection('services').doc(docId);
    DocumentSnapshot departmentDoc = await departmentRef.get();

    // update
    setState(() {
      department = departmentDoc.data();
      isLoading = false;
    });
  }
}
