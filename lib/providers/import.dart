import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:line_function_calculator/providers/function.dart';

import '../models/polyline.dart';

class Import extends ChangeNotifier {
  final String? path;
  PolyLine? line;
  FunctionProvider? functions;

  Import(this.path) {
    if (path != null) {
      load(path!, (_) => {});
    }
  }

  Future<void> load(String newPath, Function(Object?) onError) async {
    try {
      final file = File(newPath);
      final contents = await file.readAsString();
      final json = jsonDecode(contents);
      line = PolyLine.fromJson(json);
      functions = FunctionProvider.fromJson(json);
      notifyListeners();
    } on PathNotFoundException catch (e) {
      log('Error reading from $newPath', error: e);
      onError(e);
    } on FormatException catch (e) {
      log('Error reading from $newPath', error: e);
      onError(e);
    }
  }
}
