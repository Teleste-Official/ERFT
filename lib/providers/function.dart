import 'package:flutter/material.dart';

import '../models/func.dart';

class FunctionProvider extends ChangeNotifier {
  final List<Func> functions;

  FunctionProvider(this.functions);

  Map<String, dynamic> toJson() => {
        'functions':
            functions.map((func) => func.toJson()).toList(growable: false)
      };

  factory FunctionProvider.fromJson(Map<String, dynamic> json) {
    return FunctionProvider(List.from(json['functions']).map((e) => Func.fromJson(e)).toList());
  }

  void changeFunction(int index, Func newFunction) {
    functions[index].function = newFunction.function;
    functions[index].name = newFunction.name;
    notifyListeners();
  }

  void addFunction(Func newFunction) {
    functions.add(newFunction);
    notifyListeners();
  }

  void removeFunction(int index) {
    functions.removeAt(index);
    notifyListeners();
  }
}
