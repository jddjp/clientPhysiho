
import 'package:flutter/material.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';

class StepperCounter extends StatelessWidget {
  final double iconSize;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int stepperValue;

  const StepperCounter({
    required this.stepperValue,
    required this.onIncrement,
    required this.onDecrement,
    this.iconSize = textSizeNormal,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RoundedIconButton(
          icon: Icons.remove,
          iconSize: iconSize,
          onPress: onDecrement,
        ),
        Container(
          width: iconSize,
          child: Text(
            stepperValue.toString(),
            style: TextStyle(
              fontSize: iconSize * 0.8,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        RoundedIconButton(
          icon: Icons.add,
          iconSize: iconSize,
          onPress: onIncrement,
        ),
      ],
    );
  }
}

class RoundedIconButton extends StatelessWidget {
  const RoundedIconButton({
    required this.icon,
    required this.onPress,
    required this.iconSize,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPress;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      constraints: BoxConstraints.tightFor(width: iconSize, height: iconSize),
      //elevation: 6.0,
      onPressed: onPress,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(iconSize * 0.2)),
      fillColor: appColorPrimary,
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize * 0.8,
      ),
    );
  }
}
