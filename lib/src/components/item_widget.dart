import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/views/item_view.dart';

class ItemWidget extends StatefulWidget {
  final Map<String, dynamic> item;

  ItemWidget({Key key, this.item}) : super(key: key);

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    print(widget.item);
    var width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        launchScreen(context, ItemView.routeName, arguments: widget.item);
      },
      child: Column(
        children: [
          Container(
              decoration: BoxDecoration(
                  color: transparentColor,
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
                              BorderRadius.all(Radius.circular(spacing_middle)),
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
                        text(widget.item['description'],
                            textColor: textSecondaryColor,
                            fontSize: textSizeSMedium,
                            maxLine: 2),
                        Row(
                          children: [
                            text("\$${widget.item['price']}",
                                textColor: appColorAccent,
                                fontWeight: fontSemibold),
                            text("\$${widget.item['price']}",
                                textColor: appColorAccent,
                                fontWeight: fontSemibold)
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
                        text(widget.item['name'], fontWeight: fontSemibold),
                        text(widget.item['description'],
                            textColor: textSecondaryColor,
                            fontSize: textSizeSMedium,
                            maxLine: 2),
                        Row(
                          children: [
                            text("\$${widget.item['price']}",
                                textColor: appColorAccent,
                                fontWeight: fontSemibold),
                            text("\$${widget.item['price']}",
                                textColor: appColorAccent,
                                fontWeight: fontSemibold)
                          ],
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
