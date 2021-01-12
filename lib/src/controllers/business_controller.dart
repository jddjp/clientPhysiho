import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clientPhysiho/src/config/constants.dart';
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
    QuerySnapshot itemsSnapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('services', isEqualTo: businessRef)
        .orderBy('index')
        .get();

    // Load business data
    DocumentSnapshot businessDoc = await businessRef.get();
    business = {...businessDoc.data(), "id": businessDoc.id};

    Map<String, List> _itemsMap = {};
    itemsSnapshot.docs.forEach((doc) {
      Map<String, dynamic> item = doc.data();

      _itemsMap[item['id']].add({...item, "id": doc.id});
    });

    setState(() {
      items = _itemsMap;
      isLoading = false;
    });
  }

  bool isClosed() {
    final now = DateTime.now();
    final weekDay = WEEK_DAYS[now.weekday.toString()];
    final currentSchedule = business['schedules'][weekDay] != null
        ? business['schedules'][weekDay]
        : null;

    if (currentSchedule != null &&
        currentSchedule['opening_time'] != "" &&
        currentSchedule['closing_time'] == "") {
      List open = currentSchedule['opening_time'].toString().split(':');
      List close = currentSchedule['closing_time'].toString().split(':');
      final openingTime = DateTime(
          now.year, now.month, now.day, parseTime(open[0]), parseTime(open[1]));
      final closingTime = DateTime(now.year, now.month, now.day,
          parseTime(close[0]), parseTime(close[1]));

      if (now.isAfter(openingTime) && now.isBefore(closingTime) ||
          closingTime.difference(now).inMinutes < 30) {
        return false;
      }
    }

    return true;
  }

  int parseTime(String time) {
    List splitted = time.split('');

    if (splitted[0] == '0') {
      return int.parse(splitted[1]);
    }

    return int.parse(time);
  }
}
