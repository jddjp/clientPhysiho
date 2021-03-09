import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ServiceController extends ControllerMVC {
  bool isLoading = true;
  Map<String, dynamic> service;
  List<QueryDocumentSnapshot> items;

  ServiceController(String serviceId) {
    asyncData(serviceId);
  }

  void asyncData(String serviceId) async {
    print('asyncData');
    print(serviceId);
    DocumentReference serviceRef =
        FirebaseFirestore.instance.collection('services').doc(serviceId);
    QuerySnapshot itemsSnapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('services', isEqualTo: serviceRef)
        .get();

    // Load business data
    DocumentSnapshot serviceDoc = await serviceRef.get();
    service = {...serviceDoc.data(), "id": serviceDoc.id};

    setState(() {
      items = itemsSnapshot.docs;
      isLoading = false;
    });
  }

  bool isClosed() {
    final now = DateTime.now();
    final weekDay = WEEK_DAYS[now.weekday.toString()];
    final currentSchedule = service['schedules'][weekDay] != null
        ? service['schedules'][weekDay]
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
