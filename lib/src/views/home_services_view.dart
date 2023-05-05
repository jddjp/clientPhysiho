// @dart=2.9
import 'package:clientPhysiho/src/components/services_item.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clippy_flutter/arc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';

class HomeServiceView extends StatefulWidget {
  @override
  _HomeServiceViewState createState() => _HomeServiceViewState();
}

class _HomeServiceViewState extends State<HomeServiceView> {
  Future<QuerySnapshot> _servicesSnapshot;

  @override
  void initState() {
    // Query all categories
    _servicesSnapshot = FirebaseFirestore.instance
        .collection('services')
        .where('active', isEqualTo: true)
        .get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('HomeService');
    // Change status bar color
    changeStatusColor(pantoneTwo);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: const Color(0xff7c94b6),
              backgroundBlendMode: BlendMode.color,
              image: DecorationImage(
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.8), BlendMode.dstATop),
                  image: new AssetImage('assets/images/fondoph.png'),
                  fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Arc(
                        arcType: ArcType.CONVEY,
                        edge: Edge.BOTTOM,
                        height: (MediaQuery.of(context).size.width) / 25,
                        child: new Container(
                            height: (MediaQuery.of(context).size.height * 0.1),
                            width: MediaQuery.of(context).size.width,
                            color: pantoneTwo),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(),
                            Expanded(
                                child: Center(
                              child: Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    Text(
                                      "Servicios",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 25,
                                          fontFamily: 'Franklin Gothic'),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: spacing_large,
                  ),
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
                                    return ServiceItem(services: {
                                      ...snapshot.data.docs[index].data()
                                          as Map<String, dynamic>,
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
      ),
    );
  }
}
