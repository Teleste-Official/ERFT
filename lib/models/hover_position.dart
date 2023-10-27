import 'package:flutter/material.dart';

class HoverPosition extends ChangeNotifier {
  int? _value;

  set value(int? newValue) {
    // Avoid unnecessary renders by checking if value has changed
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }

  int? get value {
    return _value;
  }
}
