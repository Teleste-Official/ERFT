import 'package:flutter/material.dart';

class HoverPosition extends ChangeNotifier {
  int? _value;

  set value(int? newValue) {
    _value = newValue;
    notifyListeners();
  }

  int? get value {
    return _value;
  }
}
