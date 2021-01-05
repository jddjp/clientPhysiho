import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/views/business_view.dart';
import 'package:url_launcher/url_launcher.dart';

class OffersItem extends StatelessWidget {
  final Map<String, dynamic> offers;
  const OffersItem({Key key, this.offers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {},
      child: Container(
        decoration: boxDecoration(
          showShadow: true,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(spacing_middle)),
          child: CachedNetworkImage(
              imageUrl: offers['cover'] != ''
                  ? offers['cover']['url']
                  : 'https://firebasestorage.googleapis.com/v0/b/fisioterapia-cfb53.appspot.com/o/covers%2FVjSTmpYfxHVbo0ve.jpeg?alt=media&token=08281a69-31f9-45d6-8b94-b3d2ec9e86e2',
              fit: BoxFit.cover),
        ),
      ),
    );
  }

  void _onOfferTap(offers, context) {
    switch (offers['behavior']) {
      case 'link':
        if (offers['target'] != null) {
          launch(offers['target']);
        }
        break;
      case 'business':
        if (offers['target'] != null) {
          launchScreen(context, BusinessView.routeName,
              arguments: offers['target']);
          //Navigator.of(context).pushNamed('business', arguments: offer.business);
        }
        break;
      case 'default':
        //launch(offers.content);
        break;
    }
  }
}
