// @dart=2.9
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clientPhysiho/src/components/item_widget.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/controllers/service_controller.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

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
    //print('home');
    //print(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  ScrollController _scrollController;

  bool lastStatus = true;

  _scrollListener() {
    if (isShrink != lastStatus) {
      setState(() {
        lastStatus = isShrink;
      });
    }
  }

  bool get isShrink {
    return _scrollController.hasClients &&
        _scrollController.offset > (200 - kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    double expandHeight = MediaQuery.of(context).size.height * 0.3;
    var width = MediaQuery.of(context).size.width;
    changeStatusColor(Colors.transparent);
    print('ServiceView');
    //print(_con.isLoading);
    return Scaffold(
      body: Stack(
        children: [
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
          _con.isLoading
              ? Container(
                  width: width,
                  child: Lottie.asset('assets/images/8682-loading.json'),
                )
              : (_con.service == null
                  ? Container()
                  : NestedScrollView(
                      controller: _scrollController,
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverAppBar(
                            backgroundColor: pantoneTwo,
                            expandedHeight: expandHeight,
                            floating: true,
                            pinned: true,
                            snap: true,
                            titleSpacing: 0,
                            flexibleSpace: FlexibleSpaceBar(
                              title: Text(
                                _con.service['name'],
                                style: TextStyle(
                                    fontSize: textSizeLarge,
                                    fontWeight: fontSemibold,
                                    shadows: !isShrink
                                        ? [
                                            Shadow(
                                              blurRadius: 10.0, // shadow blur
                                              color: appleColor, // shadow color
                                              offset: Offset(2.0,
                                                  2.0), // how much shadow will be shown
                                            ),
                                          ]
                                        : null,
                                    color: !isShrink
                                        ? titleoverimage
                                        : Colors.black),
                              ),
                              background: CachedNetworkImage(
                                  imageUrl: _con.service['cover'] != ""
                                      ? _con.service['cover']['url']
                                      : 'https://firebasestorage.googleapis.com/v0/b/fisioterapia-cfb53.appspot.com/o/covers%2Flogophysihoservice.png?alt=media&token=98096b23-89a2-4c5d-81c8-fc6d56c152db',
                                  height: expandHeight,
                                  fit: BoxFit.cover),
                              collapseMode: CollapseMode.pin,
                            ),
                          )
                        ];
                      },
                      body: Container(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  /*Text(
                                    _con.service['name'],
                                    style: TextStyle(
                                        fontSize: textSizeLarge,
                                        fontWeight: fontSemibold),
                                  ),
                                  SizedBox(
                                    height: spacing_standard,
                                  ),*/
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: pantoneFourteen),
                                        borderRadius:
                                            BorderRadius.circular(40)),
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      _con.service['description'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: textSecondaryColor,
                                          fontSize: 15.0),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: spacing_standard),
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  border: Border.all(color: transparentColor),
                                  borderRadius: BorderRadius.circular(40)),
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Nuestros paquetes ofrecidos para este servicio',
                                style: TextStyle(
                                  color: pantoneTwelve,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                            _con.items != null
                                ? Expanded(
                                    child: ListView.builder(
                                        primary: false,
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: _con.items.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return ItemWidget(item: {
                                            ..._con.items[index].data()
                                                as Map<String, dynamic>,
                                            "id": _con.items[index].id,
                                            "idservice": _con.service["id"],
                                          });
                                        }))
                                : Container()
                          ],
                        ),
                      )))
        ],
      ),
    );
  }
}
