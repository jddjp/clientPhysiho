import 'package:cached_network_image/cached_network_image.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/views/service_view.dart';
import 'package:flutter/material.dart';

class ServiceItem extends StatelessWidget {
  final Map<String, dynamic> services;

  ServiceItem({Key key, this.services}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        launchScreen(context, ServiceView.routeName, arguments: services['id']);
      },
      child: Container(
        decoration: boxDecoration(
          showShadow: true,
        ),
        margin: EdgeInsets.only(
            right: spacing_standard_new,
            left: spacing_standard_new,
            bottom: spacing_standard_new),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(spacing_middle)),
              child: CachedNetworkImage(
                  imageUrl: services['logo'] != null
                      ? services['logo']['url']
                      : 'https://firebasestorage.googleapis.com/v0/b/hermez-delivery.appspot.com/o/businesses%2Flogo.png?alt=media&token=8f1908d5-0a1d-4cd7-9e68-086a4f63fbf0',
                  width: width * 0.23,
                  height: width * 0.23,
                  fit: BoxFit.fill),
            ),
            SizedBox(width: spacing_middle),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  text(services['name'], fontWeight: fontSemibold),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
