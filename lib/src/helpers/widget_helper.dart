import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';

BoxDecoration boxDecoration({double radius = spacing_middle, Color color = Colors.transparent, Color bgColor = food_white, var showShadow = false}) {
  return BoxDecoration(
    color: bgColor,
    boxShadow: showShadow ? [BoxShadow(color: food_ShadowColor, blurRadius: 6, spreadRadius: 2)] : [BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}

Widget text(String text,
    {var fontSize = textSizeMedium,
    textColor = food_textColorPrimary,
    var fontWeight = fontRegular,
    var isCentered = false,
    var maxLine = 1,
    var latterSpacing = 0.25,
    var textAllCaps = false,
    var isLongText = false}) {
  return Text(
    textAllCaps ? text.toUpperCase() : text,
    textAlign: isCentered ? TextAlign.center : TextAlign.start,
    maxLines: isLongText ? null : maxLine,
    style: TextStyle(fontFamily: GoogleFonts.poppins().fontFamily, fontWeight: fontWeight, fontSize: fontSize, color: textColor, height: 1.5, letterSpacing: latterSpacing),
  );
}

Widget mHeading(String value, {
  var fontSize = textSizeLargeMedium,
  String subtitle = ""
}) {
  return Container(
    margin: EdgeInsets.only(
      left: spacing_standard_new,
      right: spacing_standard_new
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(value, fontWeight: fontSemibold, fontSize: fontSize),
        subtitle != "" ? text(subtitle, textColor: textSecondaryColor) : Container()
      ],
    ),
  );
}

Widget mDivider(double width) {
  return Container(
      height: 0.5,
      width: width,
      color: food_view_color,
      margin: EdgeInsets.only(
      top: spacing_standard_new, bottom: spacing_standard_new
    )
  );
}

Widget mPrice(double price, { 
  discount = 0.0,
  textColor = textSecondaryColor
}) {

  if (price == 0.0) {
    return Container();
  }

  return Row(
    children: [
      Text("\$ ", style: TextStyle(color: textColor),),
      Text(price.toStringAsFixed(0), style: TextStyle(color: textColor))
    ],
  );
}