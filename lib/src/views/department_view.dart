// @dart=2.9
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clientPhysiho/src/components/business_item.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/controllers/department_controller.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/views/category_view.dart';
import 'package:clientPhysiho/src/components/search_input_widget.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class DepartmentView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'department';

  final String department;

  DepartmentView({Key key, this.department}) : super(key: key);

  @override
  _DepartmentViewState createState() => _DepartmentViewState(department);
}

class _DepartmentViewState extends StateMVC<DepartmentView> {
  DepartmentController _con;

  _DepartmentViewState(String department)
      : super(DepartmentController(department)) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final DeliveryForm _deliveryForm = DeliveryForm();
    return Scaffold(
      body: LoadingOverlay(
          isLoading: _con.isLoading,
          child: _con.department == null
              ? Container()
              : SafeArea(
                  child: _con.department['name'] == 'Lo que quieras' ||
                          _con.department['name'] == 'Super/Tienda' ||
                          _con.department['name'] == 'Mercadito Express'
                      ? SingleChildScrollView(
                          child: Column(children: [
                            Container(
                              padding: EdgeInsets.only(top: spacing_large),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CachedNetworkImage(
                                      imageUrl: _con.department['icon'],
                                      width: 100,
                                      height: 90),
                                  text(_con.department['name'],
                                      fontWeight: fontBold,
                                      fontSize: textSizeLarge),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(17.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  text(
                                      "Si cabe en nuestra maleta, te lo llevamos."),
                                  SizedBox(height: 10),
                                  Form(
                                      key: _formKey,
                                      child: Column(
                                        children: <Widget>[
                                          TextFormField(
                                            maxLines: 3,
                                            decoration: InputDecoration(
                                              labelText: "¿Qué deseas?",
                                              labelStyle: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2
                                                  .copyWith(fontSize: 16.0),
                                              filled: true,
                                              fillColor: food_white,
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(0),
                                                  borderSide: const BorderSide(
                                                      color: food_view_color,
                                                      width: 1.0)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(0),
                                                  borderSide: const BorderSide(
                                                      color: food_view_color,
                                                      width: 1.0)),
                                            ),
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Describe el producto que debemos conseguir';
                                              }

                                              return null;
                                            },
                                            style: TextStyle(
                                                fontSize: textSizeMedium),
                                            onSaved: (String value) {
                                              _deliveryForm.what = value;
                                            },
                                          ),
                                          SizedBox(height: 5),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              labelText:
                                                  "¿Dónde lo conseguimos?",
                                              labelStyle: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2
                                                  .copyWith(fontSize: 16.0),
                                              filled: true,
                                              fillColor: food_white,
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(0),
                                                  borderSide: const BorderSide(
                                                      color: food_view_color,
                                                      width: 1.0)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(0),
                                                  borderSide: const BorderSide(
                                                      color: food_view_color,
                                                      width: 1.0)),
                                            ),
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Indícanos el lugar';
                                              }

                                              return null;
                                            },
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2
                                                .copyWith(
                                                    fontSize: 16.0,
                                                    color: blackColor),
                                            onSaved: (String value) {
                                              _deliveryForm.where = value;
                                            },
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Center(
                                            child: ElevatedButton(
                                              style: TextButton.styleFrom(
                                                  primary: Colors.white,
                                                  foregroundColor:
                                                      appColorPrimary),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 30.0,
                                                    vertical: 10.0),
                                                child: text('Continuar',
                                                    textColor: whiteColor),
                                              ),
                                              onPressed: () async {
                                                /*
                                  if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();

                                      UserLocation _currentLocation = await SettingsProvider.getCurrentLocation();

                                      Uri waUrl = Uri(
                                        scheme: "https",
                                        host: "yerli.app",
                                        path: "delivery",
                                        queryParameters: {
                                          "where": _deliveryForm.where,
                                          "what": _deliveryForm.what,
                                          "location": _currentLocation.toString()
                                        }
                                      );

                                      // Reset
                                      _formKey.currentState.reset();


                                      await analytics.logEvent(
                                        name: 'yerli_delivery_contact',
                                      );

                                      // Process
                                      launch(waUrl.toString());
                                  }*/
                                              },
                                            ),
                                          ),
                                        ],
                                      ))
                                ],
                              ),
                            ),
                          ]),
                        )
                      : SingleChildScrollView(
                          child: Column(children: [
                          Container(
                            padding: EdgeInsets.only(top: spacing_large),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CachedNetworkImage(
                                    imageUrl: _con.department['icon'],
                                    width: 100,
                                    height: 90),
                                text(_con.department['name'],
                                    fontWeight: fontBold,
                                    fontSize: textSizeLarge),
                                SearchInputWidget(
                                  hintText:
                                      "Buscar ${_con.department['name'].toLowerCase()}",
                                ),
                              ],
                            ),
                          ),
                          mHeading("Categorías"),
                          SizedBox(
                            height: spacing_standard_new,
                          ),
                          Container(
                              width: double.infinity,
                              height: 80,
                              child: _con.categories != null &&
                                      _con.categories.length > 0
                                  ? ListView(
                                      padding: EdgeInsets.only(
                                          right: spacing_standard_new),
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      children: _con.categories
                                          .map((DocumentSnapshot doc) {
                                        return GestureDetector(
                                          onTap: () {
                                            launchScreen(
                                                context, CategoryView.routeName,
                                                arguments: doc['name']);
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                              left: spacing_standard_new,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: CachedNetworkImage(
                                                    imageUrl: doc['image']
                                                        ['url'],
                                                    height: 45,
                                                    width: 45,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      top: spacing_standard),
                                                  child: Text(
                                                    doc['name'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: blackColor,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  : Center(
                                      child: text("Aún no hay categorías",
                                          textColor: blackColor))),
                          SizedBox(
                            height: spacing_large,
                          ),
                          mHeading("Negocios"),
                          SizedBox(
                            height: spacing_large,
                          ),
                          _con.businesses != null && _con.businesses.length > 0
                              ? ListView.builder(
                                  primary: false,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: _con.businesses.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return BusinessItem(business: {
                                      ..._con.businesses[index].data()
                                          as Map<String, dynamic>,
                                      "id": _con.businesses[index].id,
                                    });
                                  })
                              : Center(
                                  child: text("Espéralos muy pronto",
                                      textColor: blackColor),
                                )
                        ])),
                )),
    );
  }
}

class DeliveryForm {
  String where;
  String what;

  DeliveryForm({this.where, this.what});
}
