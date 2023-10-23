import 'package:flutter/material.dart';

import '../utilities/colors.dart';

class ValuePopUp extends StatelessWidget {
  final List<String> names;
  final List<double>? values;

  const ValuePopUp({super.key, required this.names, required this.values});

  List<Widget> children() {
    List<Widget> result = [];
    if (values != null && values!.isNotEmpty) {
      for (int i = 0; i < names.length; i++) {
        final value = values?[i].toStringAsFixed(3);
        result.add(Row(
          children: [
            Text(
              names[i],
              style: TextStyle(color: FuncColor.fromIndex(i)),
            ),
            const Text('='),
            value != null ? Text(value) : const SizedBox.shrink()
          ],
        ));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children(),
      ),
    );
  }
}
