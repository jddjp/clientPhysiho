
import 'package:fluttertoast/fluttertoast.dart';
import 'package:clientPhysiho/src/models/item_option_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ItemOptionController extends ControllerMVC {
  late ItemOptionModel itemOption;
  late double _defaultPrice;
  late SingleItemOption _selectedOption; // For radio state change
  Map<String, int> _selectedOptions =
      {}; // From here we will handle item price { index: quantity }
  Map<String, bool> _checkboxSelected = {}; // For checkboxes controll

  late void Function(ItemOptionModel, Map) _triggerChange;

  // Getters
  SingleItemOption get selectedOption => _selectedOption;
  Map<String, int> get selectedOptions => _selectedOptions;
  Map<String, bool> get checkboxSelected => _checkboxSelected;

  // Dynamic getters
  int get selectedCount {
    if (itemOption.type == 'choose') return _selectedOptions.length;

    int count = 0;
    _selectedOptions.forEach((id, quantity) {
      count += quantity;
    });
    return count;
  }

  int get max => itemOption.multiple || itemOption.type == 'addon'
      ? (itemOption.max)
      : 1;
  bool get maxReached => selectedCount >= max;
  String get subtitle {
    return itemOption.multiple == true
        ? ((itemOption.max != itemOption.min
                ? "Elige entre ${itemOption.min} y ${itemOption.max} opciones"
                : "Elige ${itemOption.min} opciones"))
        : (itemOption.required == true ? "Elige una opción" : "");
  }

  // Setters

  // Comunicate with parent widget
  set triggerChange(void Function(ItemOptionModel, Map) onChange) {
    _triggerChange = onChange;
  }

  ItemOptionController(ItemOptionModel option, double price, void Function(ItemOptionModel, Map) onChange) {
    itemOption = option;
    _defaultPrice = price;
    _triggerChange = onChange;

    if (itemOption.main) {
      int mainPriceIndex = itemOption.options
          .lastIndexWhere((element) => element.price == _defaultPrice);
      if (mainPriceIndex > -1) {
        var mainPrice = itemOption.options[mainPriceIndex];
        _selectedOption = mainPrice;
        _triggerChange(itemOption, {mainPrice.id ?? '': 1});
      }
    }

    // Initialize for stepper
    if (itemOption.type == 'addon') {
      itemOption.options.forEach((opt) {
        _selectedOptions[opt.id ?? ''] = 0;
      });
    }
  }

  void incrementOption(SingleItemOption opt) {
    final key = opt.id ?? '';
    if (maxReached) {
      Fluttertoast.showToast(msg: "Sólo puedes elegir $max opciones");
      return;
    }

    setState(() {
      _selectedOptions[key] = (_selectedOptions[key] ?? 0) + 1;
      _triggerChange(itemOption, _selectedOptions);
    });
  }

  void decrementOption(SingleItemOption opt) {
    final key = opt.id ?? '';
    if ((_selectedOptions[key] ?? 0) > 0) {
      setState(() {
        _selectedOptions[key] = (_selectedOptions[key] ?? 0) - 1;
        _triggerChange(itemOption, _selectedOptions);
      });
    }
  }

  void onChangeOption(SingleItemOption opt, {required bool selected}) {
    if (itemOption.type == 'choose' && opt.active) {
      if (itemOption.max == 1 || itemOption.multiple == false) {
        setState(() {
          _selectedOption = opt; // For radio buttons
          _selectedOptions = {}; // Reset for a single option
          _selectedOptions[opt.id ?? ''] = 1;
        });
      } else {
        if (_selectedOptions[opt.id ?? ''] != null) {
          // Prevent main price
          if (itemOption.main) return;
          var selectedOptionsTmp = Map<String, int>.from(_selectedOptions);
          _selectedOptions = {};

          selectedOptionsTmp.forEach((id, quantity) {
            if (id != (opt.id ?? '')) {
              setState(() {
                _selectedOptions[id] = 1;
              });
            }
          });
        } else {
          if (maxReached) {
            if (max > 1) {
              Fluttertoast.showToast(msg: "Sólo puedes elegir $max opciones");
              return;
            }
            setState(() {
              _selectedOptions = {};
            });
          }
          setState(() {
            _selectedOptions[opt.id ?? ''] = 1;
          });
        }
      }

      _triggerChange(itemOption, _selectedOptions);
    }

    setState(() {
      _checkboxSelected[opt.id ?? ''] = selected;
    });
  }
}
