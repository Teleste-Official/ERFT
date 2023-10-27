import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hover_position.dart';
import '../providers/values.dart';
import '../utilities/colors.dart';
import 'valuepopup.dart';

class GraphPainter extends CustomPainter {
  final double xRange, yMin, yMax;
  final Map<double, List<double>> points;
  final int? hoverPosition;
  final List<Offset> crosspoints;

  GraphPainter(
      {super.repaint,
      required this.xRange,
      required this.yMin,
      required this.yMax,
      required this.points,
      required this.hoverPosition,
      required this.crosspoints});

  // x-range : 0 - total line distance
  double scaleX(Size size, double x) {
    return x * (size.width / xRange);
  }

  // y-range : min => size.height, max => 0
  double scaleY(Size size, double y) {
    if (yMax == yMin) {
      return size.height / 2;
    }
    return size.height * (1 - ((y - yMin) / (yMax - yMin)));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (xRange.isNaN || yMax.isNaN || yMin.isNaN) return;
    final scaled = points.map((key, value) {
      return MapEntry(scaleX(size, key),
          value.map((e) => scaleY(size, e)).toList(growable: false));
    });
    final xValues = scaled.keys.toList(growable: false);
    for (int i = 0; i < xValues.length - 1; i++) {
      final x0 = xValues[i];
      final x1 = xValues[i + 1];
      final yList0 = scaled[x0]!;
      final yList1 = scaled[x1]!;
      for (int j = 0; j < yList0.length; j++) {
        final y0 = yList0[j];
        final y1 = yList1[j];
        if (y0.isFinite && y1.isFinite) {
          canvas.drawLine(Offset(x0, y0), Offset(x1, y1),
              Paint()..color = FuncColor.fromIndex(j));
        }
      }
    }
    if (hoverPosition != null && scaled.length > hoverPosition!) {
      final x = xValues[hoverPosition!];
      if (!x.isNaN) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), Paint());
      }
    }
    for (int i = 0; i < crosspoints.length; i++) {
      final offset = Offset(
          scaleX(size, crosspoints[i].dx), scaleY(size, crosspoints[i].dy));
      canvas.drawCircle(offset, 5.0, Paint());
      canvas.drawLine(offset, Offset(offset.dx, size.height), Paint());
      final textPainter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
              text: 'cp${i + 1}', style: const TextStyle(color: Colors.black)));
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(offset.dx - (textPainter.width / 2), size.height));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Graph extends StatelessWidget {
  const Graph({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final valueProvider = context.watch<ValueProvider>();
    final hoverPosProvider = context.watch<HoverPosition>();
    return RepaintBoundary(
      child: CustomPaint(
        painter: GraphPainter(
          xRange: valueProvider.xRange,
          yMin: valueProvider.yMin,
          yMax: valueProvider.yMax,
          points: valueProvider.points,
          hoverPosition: hoverPosProvider.value,
          crosspoints: valueProvider.crosspoints
              .map((e) => e.point)
              .toList(growable: false),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children:
              hoverPosProvider.value != null && valueProvider.functions.isNotEmpty
                  ? [
                      Positioned(
                          top: 8.0,
                          child: ValuePopUp(
                              names: valueProvider.names,
                              values: valueProvider.points.entries
                                  .elementAt(hoverPosProvider.value!)
                                  .value))
                    ]
                  : [],
        ),
      ),
    );
  }
}
