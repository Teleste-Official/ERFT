import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class Import extends ChangeNotifier {
  Map<String, dynamic>? json;
  Future<void> load(String path) async {
    try {
      final file = File(path);
      final contents = await file.readAsString();
      json = jsonDecode(contents);
      notifyListeners();
    } catch (e) {
      debugPrint('debug: $e');
    }
  }
}
