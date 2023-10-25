import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/crosspoint.dart';
import '../models/hover_position.dart';
import '../models/polyline.dart';
import '../providers/values.dart';
import 'valuepopup.dart';

// https://www.kodeco.com/25237210-building-a-drawing-app-in-flutter

class DrawingTool extends StatefulWidget {
  /// Maximum distance between cursor and line where [ValuePopUp] is shown
  static const hoverDistance = 10.0;
  final List<Offset>? imported;
  const DrawingTool({super.key, this.imported});

  @override
  State<DrawingTool> createState() => _DrawingToolState();
}

class _DrawingToolState extends State<DrawingTool> {
  final PolyLine _path = PolyLine([]);
  bool _drawing = false;
  bool _clearPressed = false;

  @override
  void initState() {
    super.initState();
    _path.points = widget.imported ?? [];
  }

  void onHover(PointerHoverEvent event,
      {required Function(int position) onLine, required Function onDistant}) {
    if (_path.points.isEmpty) return;
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(event.position);
    final result = PolyLine.closestTo(point, _path.points);
    if (result.last < DrawingTool.hoverDistance) {
      onLine(result.first);
    } else {
      onDistant();
    }
  }

  void onPanStart(DragStartDetails details) {
    // Drawing allowed only when canvas is clear.
    if (_path.points.isNotEmpty && !_clearPressed) return;
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    setState(() {
      _path.points = [point];
      _drawing = true;
      _clearPressed = false;
    });
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (!_drawing) return;
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    setState(() {
      _path.points = [..._path.points, point];
    });
  }

  Offset crosspointPosition(Crosspoint cp, PolyLine line) {
    final ldb0 = line.ldb(cp.index);
    final ldb1 = line.ldb(cp.index + 1);
    final q = cp.point.dx - ldb0;
    final p = ldb1 - cp.point.dx;
    final x1 = line.points[cp.index].dx;
    final y1 = line.points[cp.index].dy;
    final x2 = line.points[cp.index + 1].dx;
    final y2 = line.points[cp.index + 1].dy;
    final x = (p * x1 + q * x2) / (p + q);
    final y = (p * y1 + q * y2) / (p + q);
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final polylineProvider = context.watch<PolyLine>();
    final hoverPosProvider = context.watch<HoverPosition>();
    final valuesProvider = context.watch<ValuesProvider>();
    final values = valuesProvider.points;
    final hoverPos = hoverPosProvider.value;

    final crosspoints = _clearPressed || _drawing
        ? <Offset>[]
        : valuesProvider.crosspoints
            .map((cp) => crosspointPosition(cp, polylineProvider))
            .toList(growable: false);
    
    return Stack(
      children: [
        GestureDetector(
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          onPanEnd: (_) {
            if (_path.points.isNotEmpty) {
              setState(() {
                polylineProvider.points = _path.points;
                _drawing = false;
              });
            }
          },
          child: MouseRegion(
            onHover: (event) => onHover(event,
                onLine: (position) => hoverPosProvider.value = position,
                onDistant: () => hoverPosProvider.value = null),
            child: RepaintBoundary(
              child: Container(
                color: Colors.transparent,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: CustomPaint(
                  painter: MyCustomPainter(
                      points: _clearPressed
                          ? []
                          : (_drawing ? _path.points : polylineProvider.points),
                      crossPoints: crosspoints),
                ),
              ),
            ),
          ),
        ),
        for (Offset offset in crosspoints)
          Positioned(
              top: offset.dy - 10.0,
              left: offset.dx + 10.0,
              child: Text('cp${crosspoints.indexOf(offset) + 1}')),
        Positioned(
            top: hoverPos != null && _path.points.length > hoverPos
                ? _path.points[hoverPos].dy - 10.0
                : 0.0,
            left: hoverPos != null && _path.points.length > hoverPos
                ? _path.points[hoverPos].dx + 10.0
                : 0.0,
            child: hoverPos != null &&
                    _path.points.length > hoverPos &&
                    valuesProvider.names.isNotEmpty
                ? ValuePopUp(
                    names: valuesProvider.names,
                    values: values.length > hoverPos
                        ? values.entries.elementAt(hoverPos).value
                        : [],
                  )
                : const SizedBox.shrink()),
        Positioned(
          bottom: 4.0,
          right: 4.0,
          child: values.isNotEmpty
              ? ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _clearPressed = !_clearPressed;
                    });
                  },
                  child:
                      _clearPressed ? const Text('Undo') : const Text('Clear'))
              : const SizedBox.shrink(),
        )
      ],
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final List<Offset> points;
  final List<Offset?> crossPoints;
  MyCustomPainter(
      {super.repaint, required this.points, required this.crossPoints});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    for (int i = 0; i < points.length - 1; i++) {
      Offset startPoint = points[i];
      Offset endPoint = points[i + 1];
      if (startPoint.dx >= 0 &&
          startPoint.dy >= 0 &&
          endPoint.dx >= 0 &&
          endPoint.dy >= 0 &&
          startPoint.dx <= size.width &&
          startPoint.dy <= size.height &&
          endPoint.dx <= size.width &&
          endPoint.dy <= size.height) {
        canvas.drawLine(startPoint, endPoint, paint);
      }
    }
    for (final cp in crossPoints) {
      if (cp != null) {
        canvas.drawCircle(cp, 5.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
