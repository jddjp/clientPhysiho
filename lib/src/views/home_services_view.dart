// @dart=2.9
import 'package:clientPhysiho/src/components/services_item.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clippy_flutter/arc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(
        backgroundColor: pantoneTwo,
        title: Center(child: Text("Servicios", style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontFamily: 'Franklin Gothic'),)),
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
                  image: new AssetImage('assets/images/fondoph.png'),
                  fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
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
          SafeArea(child:
          Stack(
            children: [
              Arc(
                arcType: ArcType.CONVEY,
                edge: Edge.BOTTOM,
                height: (MediaQuery.of(context).size.width) / 15,
                child: new Container(
                    height: (MediaQuery.of(context).size.height * 0.05),
                    width: MediaQuery.of(context).size.width,
                    color: pantoneTwo),
              ),
            ],
          ),
          ),
        ],
      ),
    );
  }
}
