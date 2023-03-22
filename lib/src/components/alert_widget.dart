import 'package:flutter/material.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';

class AlertWidget extends StatelessWidget {
  Color bgColor;
  String alertText;

  AlertWidget({required this.bgColor, required this.alertText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecoration(bgColor: bgColor),
      padding: EdgeInsets.all(spacing_standard),
      margin: EdgeInsets.only(bottom: spacing_standard),
      child: text(alertText,
          textColor: whiteColor, maxLine: null, fontSize: textSizeSMedium),
    );
  }
}
