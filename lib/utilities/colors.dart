import 'package:flutter/material.dart';

class FuncColor {
  static Color fromIndex(int index) {
    switch (index % 5) {
      case 0:
        return Colors.red.shade900;
      case 1:
        return Colors.blue.shade900;
      case 2:
        return Colors.green.shade900;
      case 3:
        return Colors.orange.shade900;
      case 4:
        return Colors.purple.shade900;
      default:
        return Colors.black;
    }
  }
}
