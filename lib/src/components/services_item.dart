
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/views/service_view.dart';
import 'package:flutter/material.dart';

class ServiceItem extends StatelessWidget {
  final Map<String, dynamic> services;

  ServiceItem({super.key, required this.services});
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    print('serviceItem');
    return GestureDetector(
      onTap: () {
        print("pucharar y guardar  prefernrense sharetpreferen");

        launchScreen(context, ServiceView.routeName, arguments: services['id']);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: pantoneTwelve, width: 0.4),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
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
                  imageUrl: services['logo'] != ""
                      ? services['logo']['url']
                      : 'https://firebasestorage.googleapis.com/v0/b/fisioterapia-cfb53.appspot.com/o/logos%2Flauncher_iconph.png?alt=media&token=78d21f49-9a79-43b6-bbad-2935869db94c',
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
                  text(services['name'], fontWeight: fontSemibold, isLongText: true, maxLine: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
