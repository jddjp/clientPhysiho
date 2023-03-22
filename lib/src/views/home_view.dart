// @dart=2.9
import 'package:clientPhysiho/src/components/services_item.dart';
import 'package:clientPhysiho/src/views/complete_profile_view.dart';
import 'package:clientPhysiho/src/views/home_services_view.dart';
import 'package:clientPhysiho/src/views/agend_view.dart';
import 'package:clientPhysiho/src/views/login_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:clientPhysiho/src/components/business_item.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/views/drawer_view.dart';
import 'package:clientPhysiho/src/utils/Db7BottomNavigationBar.dart';
import 'package:clientPhysiho/src/config/images.dart';

class HomeView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'home';
  String agendSetView;

  HomeView({Key key, this.agendSetView}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Future<QuerySnapshot> _servicesSnapshot;
  Placemark currentAddress;
  var _selectedIndex = 0;

  @override
  void initState() {
    _selectedIndex = 0;
    // Query all categories
    _servicesSnapshot = FirebaseFirestore.instance
        .collection('services')
        .where('active', isEqualTo: true)
        .get();
    super.initState();
  }

  void _onItemTapped(int index) {
    print('home');
    print(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _children = [
    HomeServiceView(),
    AgendView(),
    // LoginView(),
    CompleteProfileView()
  ];

  @override
  Widget build(BuildContext context) {
    print('home');
    //print(widget.agendSetView);
    widget.agendSetView != null ? _selectedIndex = 1 : '';
    widget.agendSetView = "";
    // Change status bar color
    changeStatusColor(pantoneThree);

    return Scaffold(
        bottomNavigationBar: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: dbShadowColor,
                offset: Offset.fromDirection(3, 1),
                spreadRadius: 1,
                blurRadius: 5)
          ]),
          child: Db7BottomNavigationBar(
            items: <Db7BottomNavigationBarItem>[
              Db7BottomNavigationBarItem(
                  icon: db7_ic_home,
                  title: Text("Inicio", style: TextStyle(fontSize: 16))),
              Db7BottomNavigationBarItem(
                  icon: db7_ic_calendar,
                  title: Text("Agenda", style: TextStyle(fontSize: 16))),
              Db7BottomNavigationBarItem(
                  icon: db7_ic_user,
                  title: Text("Perfil", style: TextStyle(fontSize: 16))),
            ],
            currentIndex: _selectedIndex,
            unselectedIconTheme: IconThemeData(color: pantoneSeven, size: 24),
            selectedIconTheme: IconThemeData(color: pantoneThree, size: 24),
            unselectedItemColor: pantoneSeven,
            selectedItemColor: pantoneThree,
            onTap: _onItemTapped,
            type: Db7BottomNavigationBarType.fixed,
          ),
        ),
        body: _children[_selectedIndex]);
  }
}
