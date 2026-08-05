
import 'package:flutter/material.dart';
import 'package:clientPhysiho/src/components/stepper_counter.dart';
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/controllers/item_option_controller.dart';
import 'package:clientPhysiho/src/helpers/widget_helper.dart';
import 'package:clientPhysiho/src/models/item_option_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ittemOptionWidget extends StatefulWidget {
  final ItemOptionModel ittemOption;
  final double price;
  final void Function(ItemOptionModel, Map) onChange;
  final Map<String, String> errors;

  ittemOptionWidget({
    required this.ittemOption,
    required this.price,
    required this.onChange,
    required this.errors,
    super.key,
  });

  @override
  _ittemOptionWidgetState createState() =>
      _ittemOptionWidgetState(ittemOption, price, onChange);
}

class _ittemOptionWidgetState extends StateMVC<ittemOptionWidget> {
  late ItemOptionController _con;

  _ittemOptionWidgetState(ItemOptionModel option, double price, void Function(ItemOptionModel, Map) onChange)
      : super(ittemOptionController(option, price, onChange)) {
    _con = controller as ItemOptionController;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      decoration: boxDecoration(radius: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: spacing_standard,
          ),
          optionTitle(),
          ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: _con.itemOption.options.length,
            itemBuilder: (BuildContext context, index) {
              SingleItemOption option =
                  _con.itemOption.options.elementAt(index);
              if (option.active == false) {
                return Container();
              }

              if (_con.itemOption.type == 'addon') {
                return Container(
                  margin: EdgeInsets.only(
                      left: spacing_standard_new, bottom: spacing_standard),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            text(option.name ?? ''),
                            mPrice(option.price, discount: option.discount)
                          ],
                        ),
                      ),
                      StepperCounter(
                        stepperValue: _con.selectedOptions[option.id ?? ''] ?? 0,
                        onIncrement: () {
                          _con.incrementOption(option);
                        },
                        onDecrement: () {
                          _con.decrementOption(option);
                        },
                      )
                    ],
                  ),
                );
              } else if (_con.itemOption.max == 1 ||
                  _con.itemOption.multiple == false) {
                return RadioListTile<SingleItemOption>(
                    title: Text(option.name ?? ''),
                    subtitle: mPrice(option.price, discount: option.discount),
                    value: option,
                    controlAffinity: ListTileControlAffinity.trailing,
                    groupValue: _con.selectedOption,
                    onChanged: (selected) {
                      if (selected != null) {
                        _con.onChangeOption(option, selected: true);
                      }
                    });
              } else {
                return CheckboxListTile(
                    title: Text(option.name ?? ''),
                    subtitle: mPrice(option.price, discount: option.discount),
                    value: _con.checkboxSelected[option.id ?? ''] ?? false,
                    onChanged: (selected) {
                      _con.onChangeOption(option, selected: selected ?? false);
                    });
              }
            },
          )
        ],
      ),
    );
  }

  Widget optionTitle() {
    return Container(
      margin: EdgeInsets.only(
          left: spacing_standard_new, right: spacing_standard_new),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(_con.itemOption.name ?? '',
                    fontWeight: fontSemibold, fontSize: textSizeLargeMedium),
                widget.errors[_con.itemOption.id ?? ''] != null
                    ? text(widget.errors[_con.itemOption.id ?? ''] ?? '',
                        textColor: Colors.red, fontSize: textSizeSMedium)
                    : (_con.subtitle != ""
                        ? text(_con.subtitle,
                            textColor: textSecondaryColor,
                            fontSize: textSizeSMedium)
                        : Container())
              ],
            ),
          ),
          _con.itemOption.required == true
              ? Container(
                  decoration: boxDecoration(
                      bgColor: widget.errors[_con.itemOption.id ?? ''] != null
                          ? Colors.red
                          : Colors.grey[400] ?? Colors.grey),
                  padding: EdgeInsets.symmetric(horizontal: spacing_control),
                  margin: EdgeInsets.only(top: spacing_standard),
                  child: text("Obligatorio",
                      textColor: whiteColor, fontSize: textSizeSmall),
                )
              : Container()
        ],
      ),
    );
  }

  static ControllerMVC ittemOptionController(ItemOptionModel option, double price, void Function(ItemOptionModel, Map) onChange) {
    return ItemOptionController(option, price, onChange);
  }
}
