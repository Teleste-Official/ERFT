import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/func.dart';
import '../providers/function.dart';
import '../utilities/colors.dart';

class FunctionInput extends StatefulWidget {
  const FunctionInput({
    super.key,
  });

  @override
  State<FunctionInput> createState() => _FunctionInputState();
}

class _FunctionInputState extends State<FunctionInput> {
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  late FocusNode _focusNode;
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FunctionProvider>();

    final functions = provider.functions;
    return ListView.builder(
        itemCount: functions.length + 1,
        itemBuilder: ((context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: FunctionListItem(
              key: GlobalKey(),
              color: index < functions.length
                  ? FuncColor.fromIndex(index)
                  : Colors.black,
              function: index < functions.length
                  ? functions[index]
                  : Func('f${provider.functions.length}', ''),
              lastItem: index == functions.length,
              onAdd: (func) => provider.addFunction(func),
              onChange: (func) => provider.changeFunction(index, func),
              onRemove: () => provider.removeFunction(index),
              focus: index == functions.length ? _focusNode : null,
            ),
          );
        }));
  }
}

class FunctionListItem extends StatefulWidget {
  final Color color;
  final Func function;
  final bool lastItem;
  final FocusNode? focus;
  final void Function(Func func) onAdd;
  final void Function(Func func) onChange;
  final void Function() onRemove;

  const FunctionListItem({
    super.key,
    required this.function,
    required this.lastItem,
    required this.onAdd,
    required this.onChange,
    required this.onRemove,
    required this.focus,
    required this.color,
  });

  @override
  State<FunctionListItem> createState() => _FunctionListItemState();
}

class _FunctionListItemState extends State<FunctionListItem> {
  /// + 0 = ADD (Last item of the list, not plotted)
  /// + 1 = REMOVE (Plotted items that are not modified)
  /// + 2 = CONFIRM / UNDO (Plotted items that are modified)
  late int state;
  final _nameController = TextEditingController();
  final _funcController = TextEditingController();
  
  void onAdd() {
    final formatted = Func.format(_funcController.text);
    if (Func.validate(
      formatted,
      onError: (errorMessage) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add function ${_nameController.text}: $errorMessage')));
      },
    )) {
      widget.onAdd(Func(_nameController.text, formatted));
    }
  }

  void onChange() {
    final formatted = Func.format(_funcController.text);
    if (Func.validate(
      formatted,
      onError: (errorMessage) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to change function ${_nameController.text}: $errorMessage')));
      },
    )) {
      widget.onChange(Func(_nameController.text, formatted));
    }
  }

  Widget firstButton() {
    switch (state) {
      case 0:
        return Button(type: ButtonType.add, onPressed: onAdd);
      case 1:
        return Button(
            type: ButtonType.remove, onPressed: widget.onRemove);
      default:
        return Button(type: ButtonType.confirm, onPressed: onChange);
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.function.name;
    _funcController.text = widget.function.function;
    state = widget.lastItem ? 0 : 1;
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _funcController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            width: 100,
            child: TextField(
              onChanged: (value) {
                if (!widget.lastItem &&
                    (value != widget.function.name ||
                        Func.format(_funcController.text) !=
                            widget.function.function)) {
                  setState(() {
                    state = 2;
                  });
                } else if (!widget.lastItem) {
                  setState(() {
                    state = 1;
                  });
                }
              },
              style: TextStyle(color: widget.color),
              controller: _nameController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: widget.color)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: widget.color))),
            )),
        const SizedBox(
          width: 25,
          child: Center(child: Text('=')),
        ),
        Expanded(
            child: TextField(
          focusNode: widget.focus?..requestFocus(),
          controller: _funcController,
          onSubmitted: (_) {
            if (state == 0) {
              onAdd();
            }
            if (state == 2) {
              onChange();
            }
          },
          onChanged: (value) {
            if (!widget.lastItem &&
                (Func.format(value) != widget.function.function ||
                    _nameController.text != widget.function.name)) {
              setState(() {
                state = 2;
              });
            } else if (!widget.lastItem) {
              setState(() {
                state = 1;
              });
            }
          },
          decoration: const InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            focusedBorder: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2)),
          ),
        )),
        const SizedBox(
          width: 25,
        ),
        SizedBox(width: 100, child: firstButton()),
        const SizedBox(
          width: 25,
        ),
        SizedBox(
            width: 100,
            child: state < 2
                ? null
                : Button(
                    type: ButtonType.undo,
                    onPressed: () {
                      _nameController.text = widget.function.name;
                      _funcController.text = widget.function.function;
                      setState(() {
                        state = 1;
                      });
                    }))
      ],
    );
  }
}

enum ButtonType { add, remove, confirm, undo }

class Button extends StatelessWidget {
  final ButtonType type;
  final void Function()? onPressed;
  const Button({super.key, required this.type, required this.onPressed});
  Text text(ButtonType type) {
    switch (type) {
      case ButtonType.add:
        return const Text('add');
      case ButtonType.remove:
        return const Text('remove');
      case ButtonType.confirm:
        return const Text('confirm');
      case ButtonType.undo:
        return const Text('undo');
    }
  }

  Color color(ButtonType type) {
    switch (type) {
      case ButtonType.remove:
        return Colors.red;
      case ButtonType.undo:
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(color(type))),
        onPressed: onPressed,
        child: text(type));
  }
}
