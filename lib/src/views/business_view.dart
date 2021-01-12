import 'package:clientPhysiho/src/utils/Db7BottomNavigationBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clientPhysiho/src/components/item_widget.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/config/images.dart';
import 'package:clientPhysiho/src/controllers/business_controller.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/providers/cart_provider.dart';
import 'package:clientPhysiho/src/services/search_delegate.dart';
import 'package:clientPhysiho/src/views/cart_view.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';

import 'drawer_view.dart';

class BusinessView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'business';
  final String businessId;

  BusinessView({Key key, this.businessId}) : super(key: key);

  @override
  _BusinessViewState createState() => _BusinessViewState(businessId);
}

class _BusinessViewState extends StateMVC<BusinessView> {
  BusinessController _con;
  var _selectedIndex = 0;
  _BusinessViewState(String businessId)
      : super(BusinessController(businessId)) {
    _con = controller;
  }

  void _onItemTapped(int index) {
    print('home');
    print(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double expandHeight = MediaQuery.of(context).size.height * 0.3;
    var width = MediaQuery.of(context).size.width;
    print(_con.business['name']);

    return Scaffold(
      backgroundColor: appLayout_background,
      drawer: DrawerView(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: dbShadowColor,
              offset: Offset.fromDirection(3, 1),
              spreadRadius: 1,
              blurRadius: 5)
        ]),
        child: Db7BottomNavigationBar(
          items: const <Db7BottomNavigationBarItem>[
            Db7BottomNavigationBarItem(
                icon: db7_ic_home,
                title: Text("Inicio", style: TextStyle(fontSize: 16))),
            Db7BottomNavigationBarItem(
                icon: db7_ic_leaf,
                title: Text("Service", style: TextStyle(fontSize: 16))),
            Db7BottomNavigationBarItem(
                icon: db7_ic_chat,
                title: Text("Notice", style: TextStyle(fontSize: 16))),
            Db7BottomNavigationBarItem(
                icon: db7_ic_user,
                title: Text("Perfil", style: TextStyle(fontSize: 16))),
          ],
          currentIndex: _selectedIndex,
          unselectedIconTheme:
              IconThemeData(color: db7_textColorSecondary, size: 24),
          selectedIconTheme: IconThemeData(color: db7_colorPrimary, size: 24),
          unselectedItemColor: db7_textColorSecondary,
          selectedItemColor: db7_colorPrimary,
          onTap: _onItemTapped,
          type: Db7BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
