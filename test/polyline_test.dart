import 'package:flutter_test/flutter_test.dart';
import 'package:line_function_calculator/models/polyline.dart';

void main() {
  group('pythagoras', () {
    test('postive pyhtagoras', () {
      const b = Offset(3, 0);
      const c = Offset(0, 4);
      expect(PolyLine.distanceBetweenPoints(b, c), 5.0);
    });
    test('negative pyhtagoras', () {
      const b = Offset(-3, 0);
      const c = Offset(0, -4);
      expect(PolyLine.distanceBetweenPoints(b, c), 5.0);
    });
  });

  group('line distance', () {
    const a = Offset(0, 0);
    const b = Offset(3, 0);
    const c = Offset(0, 4);
    const line = [a, b, c, a];
    PolyLine path = PolyLine(line);
    test('line distance beginning at 0', () {
      expect(path.ldb(0), 0.0);
    });
    test('line distance beginning at 1', () {
      expect(path.ldb(1), 3.0);
    });
    test('line distance beginning at 2', () {
      expect(path.ldb(2), 3.0 + 5.0);
    });
    test('line distance end at 0', () {
      expect(path.lde(0), 4.0 + 5.0 + 3.0);
    });
    test('line distance end at 1', () {
      expect(path.lde(1), 4.0 + 5.0);
    });
    test('line distance end at 2', () {
      expect(path.lde(2), 4.0);
    });
    test('line distance end at 3', () {
      expect(path.lde(3), 0.0);
    });

    test('total line distance', () {
      expect(path.totalLineDistance, 3.0 + 5.0 + 4.0);
    });
  });
}
