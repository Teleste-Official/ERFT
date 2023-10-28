import 'dart:ui';

import 'package:function_tree/function_tree.dart';

import '../models/func.dart';
import '../models/polyline.dart';
import '../models/crosspoint.dart';

class ValueProvider {
  final PolyLine line;
  final List<Func> functions;
  /// key: x-value, value: function values
  late final Map<double, List<double>> points;
  late final List<Crosspoint> crosspoints;

  ValueProvider(this.line, this.functions) {
    points = _calculatePoints();
    crosspoints = _calculateCrosspoints();
  }

  List<String> get names {
    return functions.map((func) => func.name).toList(growable: false);
  }

  double get xRange {
    return points.isEmpty ? double.nan : points.keys.last;
  }

  double get yMax {
    var result = double.nan;
    points.forEach((_, list) {
      result = list.fold(
          result,
          (previousValue, element) => element.isFinite &&
                  (element > previousValue || previousValue.isNaN)
              ? element
              : previousValue);
    });
    return result;
  }

  double get yMin {
    var result = double.nan;
    points.forEach((_, list) {
      result = list.fold(
          result,
          (previousValue, element) =>
              element < previousValue || previousValue.isNaN
                  ? element
                  : previousValue);
    });
    return result;
  }

  Map<double, List<double>> _calculatePoints() {
    final Map<double, List<double>> result = {};
    for (int i = 0; i < line.length; i++) {
      final x = line.ldb(i);
      final List<double> yValues = [];
      for (final function in functions.map((e) => e.function)) {
        yValues.add(_calculate(i, function));
      }
      result.putIfAbsent(x, () => yValues);
    }
    return result;
  }

  List<Crosspoint> _calculateCrosspoints() {
    if (points.isEmpty) return [];
    final List<Crosspoint> result = [];
    for (int f = 0; f < functions.length - 1; f++) {
      for (int x = 0; x < points.length - 1; x++) {
        final x0 = points.keys.elementAt(x);
        final x1 = points.keys.elementAt(x + 1);
        final fy0 = points.entries.elementAt(x).value[f];
        final fy1 = points.entries.elementAt(x + 1).value[f];
        for (int g = f + 1; g < functions.length; g++) {
          final gy0 = points.entries.elementAt(x).value[g];
          final gy1 = points.entries.elementAt(x + 1).value[g];
          if (fy0.isFinite && fy1.isFinite && gy0.isFinite && gy1.isFinite) {
            if (fy0 > gy0 && fy1 < gy1) {
              final intersection = _intersection(x0, x1, fy0, fy1, gy0, gy1);
              if (intersection != null) {
                result.add(
                    Crosspoint(Offset(intersection[0], intersection[1]), x));
              }
            } else if (fy0 < gy0 && fy1 > gy1) {
              final intersection = _intersection(x0, x1, gy0, gy1, fy0, fy1);
              if (intersection != null) {
                result.add(
                    Crosspoint(Offset(intersection[0], intersection[1]), x));
              }
            }
          }
        }
      }
    }
    return result..sort();
  }

  String _calculateVariables(int index, String function) {
    function = function.replaceAll('BLDB', line.bldb(index).toString());
    function = function.replaceAll('BLDE', line.blde(index).toString());
    function = function.replaceAll('LDB', line.ldb(index).toString());
    function = function.replaceAll('LDE', line.lde(index).toString());

    return function;
  }

  double _calculate(int index, String function) {
    final valueString = _calculateVariables(index, function);
    return valueString.interpret().toDouble();
  }

  List<double> yValues(int index) {
    return points.values.map((e) => e[index]).toList(growable: false);
  }

// https://stackoverflow.com/questions/385305/efficient-maths-algorithm-to-calculate-intersections

  List<double>? _intersection(
      double x0, double x1, double y0, double y1, double y2, double y3) {
    final dx = x0 - x1;
    final y01 = y0 - y1;
    final y23 = y2 - y3;
    final c = dx * (y23 - y01);
    if (c.abs() < 0.01) {
      return null;
    }
    final a = x0 * y1 - y0 * x1;
    final b = x0 * y3 - y2 * x1;

    final x = (dx * (a - b)) / c;
    final y = (a * y23 - b * y01) / c;
    return [x, y];
  }
}
