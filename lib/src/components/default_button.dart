import 'package:flutter/material.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    Key key,
    this.text,
    this.press,
  }) : super(key: key);
  final String text;
  final Function press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.0,
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        color: food_color_green_gradient2,
        onPressed: press,
        child: Text(
          text,
          style: TextStyle(
            fontSize: textSizeMedium,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
