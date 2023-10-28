import 'dart:math';
import 'package:flutter/material.dart';

class PolyLine extends ChangeNotifier {
  List<Offset> _points;

  PolyLine(this._points);

  set points(List<Offset> newPath) {
    _points = newPath;
    notifyListeners();
  }

  List<Offset> get points {
    return _points;
  }

  double get totalLineDistance {
    return ldb(_points.length - 1);
  }

  int get length {
    return _points.length;
  }

  Map<String, dynamic> toJson() => {
        'polyline':
            points.map((offset) => {'x': offset.dx, 'y': offset.dy}).toList()
      };

  factory PolyLine.fromJson(Map<String, dynamic> json) {
    return PolyLine(List.from(json['polyline'])
        .map((e) => Offset(e['x'] as double, e['y'] as double))
        .toList());
  }
  
  static double distanceBetweenPoints(Offset p1, Offset p2) {
    return sqrt(pow((p1.dx - p2.dx), 2) + pow((p1.dy - p2.dy), 2));
  }

  /// Retuns index in [points] (first element) that is closest to [p] and distance (second element).
  static List<dynamic> closestTo(Offset p, List<Offset> points) {
    var distances =
        points.map((point) => distanceBetweenPoints(point, p)).toList();
    int index = 0;
    for (int i = 0; i < distances.length - 1; i++) {
      if (distances[i + 1] < distances[index]) {
        index = i + 1;
      }
    }
    return [index, distances[index]];
  }

  /// Bee line distance from beginning
  double bldb(int index) {
    return distanceBetweenPoints(_points[index], _points.first);
  }

  /// Bee line distance from end
  double blde(int index) {
    return distanceBetweenPoints(_points[index], _points.last);
  }

  /// Line distance from beginning
  double ldb(int index) {
    double result = 0.0;
    for (int i = 0; i < index; i++) {
      result += distanceBetweenPoints(_points[i], _points[i + 1]);
    }
    return result;
  }

  /// Line distance from end
  double lde(int index) {
    double result = 0.0;
    for (int i = _points.length - 2; i >= index; i--) {
      result += distanceBetweenPoints(_points[i], _points[i + 1]);
    }
    return result;
  }
}
