import 'package:cached_network_image/cached_network_image.dart';
import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

class HomeView extends StatefulWidget {
  // Route name for this view
  static const routeName = '/';

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Future<QuerySnapshot> _departmentSnapshot;
  Future<QuerySnapshot> _lastBusinessesSnapshot;
  Future<QuerySnapshot> _offersSnapshot;

  @override
  void initState() {
    // Query all categories
    _departmentSnapshot = FirebaseFirestore.instance
        .collection('services')
        .where('active', isEqualTo: true)
        .orderBy('index')
        .get();
    _offersSnapshot = FirebaseFirestore.instance
        .collection('services')
        .where('active', isEqualTo: true)
        .orderBy('index')
        .get();
    _lastBusinessesSnapshot = FirebaseFirestore.instance
        .collection('services')
        .where('active', isEqualTo: true)
        .orderBy('index')
        .get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Change status bar color
    changeStatusColor(primaryColor);

    return Scaffold(
      backgroundColor: Color(0xFFFCFBFB),
      drawer: DrawerView(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(children: [
                Arc(
                  arcType: ArcType.CONVEX,
                  edge: Edge.BOTTOM,
                  height: (MediaQuery.of(context).size.width) / 25,
                  child: new Container(
                      height: (MediaQuery.of(context).size.height * 0.37),
                      width: MediaQuery.of(context).size.width,
                      color: primaryColor),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Builder(builder: (context) {
                            return IconButton(
                              icon: Icon(
                                Icons.menu,
                                color: whiteColor,
                              ),
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer(),
                            );
                          }),
                          text(
                              "${context.watch<LocationProvider>().address.thoroughfare} ${context.watch<LocationProvider>().address.name}",
                              textColor: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                    transform: Matrix4.translationValues(0.0, 145.0, 0.0),
                    height: 120,
                    child: FutureBuilder<QuerySnapshot>(
                        future: _departmentSnapshot,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          return ListView(
                            padding: EdgeInsets.only(right: 16),
                            scrollDirection: Axis.horizontal,
                            children:
                                snapshot.data.docs.map((DocumentSnapshot doc) {
                              print(
                                  "==============home_view=====================");
                              print(doc['logo']['url']);
                              print(doc['index'].toString());
                              print(doc['index'].toString().isEmpty);
                              return GestureDetector(
                                onTap: () {
                                  // View department
                                  launchScreen(
                                      context, DepartmentView.routeName,
                                      arguments: doc.id);
                                },
                                child: Container(
                                  width: 93.0,
                                  margin: EdgeInsets.only(
                                    left: 20,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      CircleAvatar(
                                        backgroundColor: pantoneblueColor,
                                        radius: 30,
                                        backgroundImage: NetworkImage(doc[
                                                    'logo']
                                                .toString()
                                                .isEmpty
                                            ? 'https://firebasestorage.googleapis.com/v0/b/fisioterapia-cfb53.appspot.com/o/logos%2FFisioterapiaDeportivareverso.png?alt=media&token=5885aa92-655a-4c8f-a10b-fb33851444d8'
                                            : doc['logo']['url'].toString()),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        child: Text(
                                          doc['name'].toString(),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        })),
              ]),
              Container(
                  padding: EdgeInsets.symmetric(vertical: spacing_standard_new),
                  child: FutureBuilder<QuerySnapshot>(
                      future: _offersSnapshot,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snap) {
                        if (snap.hasError) {
                          return Text('Something went wrong');
                        }
                        if (snap.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snap.data.docs.length == 0) {
                          return SizedBox();
                        }
                        return Column(children: [
                          mHeading('Ofertas'),
                          SizedBox(height: spacing_standard_new),
                          CarouselSlider.builder(
                            itemCount: snap.data.docs.length,
                            options: CarouselOptions(
                              aspectRatio: 2.0,
                              enlargeCenterPage: true,
                              autoPlay: true,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return OffersItem(offers: {
                                ...snap.data.docs[index].data(),
                                "id": snap.data.docs[index].id
                              });
                            },
                          ),
                        ]);
                      })),
              Container(
                padding: EdgeInsets.symmetric(vertical: spacing_standard_new),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    mHeading('Últimos negocios'),
                    SizedBox(height: spacing_standard_new),
                    FutureBuilder(
                        future: _lastBusinessesSnapshot,
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
                              itemBuilder: (BuildContext context, int index) {
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
    );
  }
}
