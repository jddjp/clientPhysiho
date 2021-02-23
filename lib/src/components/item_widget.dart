import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/views/item_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  final String idservice;
  ItemWidget({Key key, this.item, this.idservice}) : super(key: key);

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  SharedPreferences _idservices;
  @override
  void initState() {
    super.initState();
    initialize();
    //initializeFlutterFire();
  }

  void initialize() async {
    _idservices = await SharedPreferences.getInstance();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print("servicio ty");
    print(widget.item["idservice"]);
    print(widget.item);
    var width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        //id servicio y id de paquete de servicio
        _idservices.setString('idservicio', widget.item["idservice"]);
        _idservices.setString('idpaqueteservicio', widget.item["id"]);
        print(widget.item["idservice"]);
        print(widget.item["id"]);
        print("guardando realizando set guardoado de id");
        launchScreen(context, ItemView.routeName, arguments: widget.item);
      },
      child: Column(
        children: [
          Container(
              decoration: BoxDecoration(
                  color: whiteColor,
                  border: Border.all(color: pantoneFive),
                  borderRadius: BorderRadius.circular(20)),
              margin: EdgeInsets.only(
                  right: spacing_standard_new,
                  left: spacing_standard_new,
                  bottom: spacing_standard_new),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  widget.item['image'] != null
                      ? ClipRRect(
                          borderRadius:
                              BorderRadius.all(Radius.circular(spacing_large)),
                          child: CachedNetworkImage(
                              imageUrl: widget.item['image']['url'],
                              width: width * 0.23,
                              height: width * 0.23,
                              fit: BoxFit.cover),
                        )
                      : ClipRRect(
                          borderRadius:
                              BorderRadius.all(Radius.circular(spacing_middle)),
                          child: Image.asset(
                            'assets/images/launcher_iconph.png',
                            width: width * 0.23,
                            height: width * 0.23,
                            fit: BoxFit.cover,
                          ),
                        ),
                  SizedBox(width: spacing_middle),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        text(widget.item['name'], fontWeight: fontSemibold),
                        text('Sesiones: ' + widget.item['sesion'].toString(),
                            textColor: textSecondaryColor,
                            fontSize: textSizeSMedium,
                            maxLine: 2),
                        Row(
                          children: [
                            text("\$${widget.item['price']}",
                                textColor: appColorAccent,
                                fontWeight: fontSemibold),
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: pantoneThree,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Text(
                            'Comprar',
                            style: TextStyle(
                                color: whiteColor, fontWeight: fontSemibold),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
