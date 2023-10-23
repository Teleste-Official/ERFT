import 'dart:ui';

class Crosspoint implements Comparable<Crosspoint> {
  final Offset point;
  final int index;

  Crosspoint(this.point, this.index);

  @override
  int compareTo(Crosspoint other) {
    return index.compareTo(other.index);
  }
}
