import 'package:clientPhysiho/src/controllers/service_controller.dart';
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

class ServiceView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'business';
  final String serviceId;

  ServiceView({Key key, this.serviceId}) : super(key: key);

  @override
  _ServiceViewState createState() => _ServiceViewState(serviceId);
}

class _ServiceViewState extends StateMVC<ServiceView> {
  ServiceController _con;
  var _selectedIndex = 0;
  _ServiceViewState(String serviceId) : super(ServiceController(serviceId)) {
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
    print('Business');
    print(_con.service['name']);
    print(_con.service['logo']['url']);

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
      body: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xff7c94b6),
              backgroundBlendMode: BlendMode.color,
              image: DecorationImage(
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.8), BlendMode.dstATop),
                  image: new AssetImage('assets/images/fondoph.png'),
                  fit: BoxFit.fitHeight),
            ),
          ),
          LoadingOverlay(
            isLoading: _con.isLoading,
            child: _con.service == null
                ? Container()
                : NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxScrolled) {
                      changeStatusColor(
                          innerBoxScrolled ? Colors.white : Colors.transparent);
                      return <Widget>[
                        SliverAppBar(
                          expandedHeight: expandHeight,
                          floating: false,
                          forceElevated: innerBoxScrolled,
                          pinned: true,
                          titleSpacing: 0,
                          backgroundColor: primaryColor,
                          title: Container(
                            height: 60,
                            child: Container(
                              width: width,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  innerBoxScrolled == true
                                      ? text(_con.service['name'],
                                          fontWeight: fontSemibold,
                                          fontSize: textSizeNormal)
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                          flexibleSpace: FlexibleSpaceBar(
                            background: Container(
                              child: CachedNetworkImage(
                                  imageUrl: _con.service['cover'] != ""
                                      ? _con.service['cover']['url']
                                      : 'https://firebasestorage.googleapis.com/v0/b/hermez-delivery.appspot.com/o/businesses%2Flogo.png?alt=media&token=8f1908d5-0a1d-4cd7-9e68-086a4f63fbf0',
                                  height: expandHeight,
                                  fit: BoxFit.cover),
                            ),
                            collapseMode: CollapseMode.pin,
                          ),
                        ),
                      ];
                    },
                    body: Stack(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(14),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    text(_con.service['name'],
                                        textColor: Colors.black)
                                  ],
                                ),
                                SizedBox(height: spacing_standard),
                                _con.items != null
                                    ? ListView.builder(
                                        primary: false,
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: _con.items.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return ItemWidget(item: {
                                            ..._con.items[index].data(),
                                            "id": _con.items[index].id,
                                          });
                                        })
                                    : Container()
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
