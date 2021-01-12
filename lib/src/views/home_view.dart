import 'package:cached_network_image/cached_network_image.dart';
import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:clientPhysiho/src/components/business_item.dart';
import 'package:clientPhysiho/src/components/offers_item.dart';
import 'package:clientPhysiho/src/components/search_input_widget.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/providers/cart_provider.dart';
import 'package:clientPhysiho/src/providers/location_provider.dart';
import 'package:clientPhysiho/src/views/cart_view.dart';
import 'package:clientPhysiho/src/views/department_view.dart';
import 'package:clientPhysiho/src/views/tracking_view.dart';
import 'package:clientPhysiho/src/views/drawer_view.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:clientPhysiho/src/utils/Db7BottomNavigationBar.dart';
import 'package:clientPhysiho/src/config/images.dart';

class HomeView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'home';

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
        .orderBy('index')
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

  @override
  Widget build(BuildContext context) {
    // Change status bar color
    changeStatusColor(primaryColor);

    return Scaffold(
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
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: const Color(0xff7c94b6),
                backgroundBlendMode: BlendMode.color,
                image: DecorationImage(
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.8), BlendMode.dstATop),
                    image: new AssetImage('assets/images/Fondo.png'),
                    fit: BoxFit.fitHeight),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Builder(builder: (context) {
                              return IconButton(
                                  icon: Icon(
                                    Icons.menu,
                                    color: primaryColor,
                                  ),
                                  onPressed: () =>
                                      Scaffold.of(context).openDrawer());
                            }),
                          ],
                        ),
                      ),
                    ]),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: spacing_standard_new),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: spacing_standard_new),
                          FutureBuilder(
                              future: _servicesSnapshot,
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Something went wrong');
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator(
                                    backgroundColor: appColorAccent,
                                  ));
                                }

                                return ListView.builder(
                                    primary: false,
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: snapshot.data.docs.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return BusinessItem(business: {
                                        ...snapshot.data.docs[index].data(),
                                        "id": snapshot.data.docs[index].id
                                      });
                                    });
                              }),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
