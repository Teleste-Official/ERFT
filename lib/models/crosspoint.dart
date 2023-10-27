import 'dart:ui';

/// [point] is the exact location of two lines crossing<br />
/// [point] is between [index] and [index] + 1 in [PolyLine]
class Crosspoint implements Comparable<Crosspoint> {
  final Offset point;
  final int index;

  Crosspoint(this.point, this.index);

  @override
  int compareTo(Crosspoint other) {
    return index.compareTo(other.index);
  }
}
