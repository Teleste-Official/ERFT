class Func {
  String name;
  String function;
  Func(this.name, this.function);

  static String format(String string) {
    return string.replaceAll(' ', '').replaceAll(',', '.').toUpperCase();
  }

  Map<String, dynamic> toJson() => {'name': name, 'function': function};

  factory Func.fromJson(Map<String, dynamic> json) {
    return Func(json['name'] as String, json['function'] as String);
  }

  /// Variables for the functions
  /// + LDB = Line distance from beginning
  /// + LDE = Line distance from end
  /// + BLDB = Bee line distance from beginning
  /// + BLDE = Bee line distance from end
  static const List<String> variables = ['LDB', 'LDE', 'BLDB', 'BLDE'];

  /// Operations for the functions
  /// + addition (+)
  /// + substraction (-)
  /// + multiplication (*)
  /// + division (/)
  /// + exponent (^)
  static const String operations = r'[\+\*\-\/\^]';

  /// Returns null if succesfull, error message if failed
  static String? _operationsCheck(String string) {
    final re = RegExp(operations);
    int index = string.lastIndexOf(re);

    while (index > 0) {
      final right = string.substring(index + 1);
      // tryParse instead of parse to avoid throwing
      if (!variables.contains(right) && double.tryParse(right) == null) {
        return '$right is not a number/variable';
      }
      string = string.substring(0, index);
      index = string.lastIndexOf(re);
    }
    if (!variables.contains(string) && double.tryParse(string) == null) {
      return '$string is not a number/variable';
    }
    return null;
  }

  /// Returns true if validation is succesfull
  static bool validate(String? string,
      {void Function(String errorMessage)? onError}) {
    if (string == null || string.isEmpty || string == '') {
      if (onError != null) {
        onError('Function is empty');
      }
      return false;
    }

    final illegalChar = string.replaceAll(RegExp(r'[A-Z0-9\+\*\^\-\./()]'), '');
    if (illegalChar.isNotEmpty) {
      if (onError != null) {
        onError('Illegal character: $illegalChar');
      }
      return false;
    }
    final invalidExpressions = string.split(RegExp(r'[^A-Z]'))
      ..removeWhere(
          (element) => element.isEmpty || variables.contains(element));
    if (invalidExpressions.isNotEmpty) {
      if (onError != null) {
        onError('Invalid variable: ${invalidExpressions.join('|')}');
        return false;
      }
    }
    if ('('.allMatches(string).length > ')'.allMatches(string).length) {
      if (onError != null) {
        onError('Syntax error: expected )');
        return false;
      }
    }

    if ('('.allMatches(string).length < ')'.allMatches(string).length) {
      if (onError != null) {
        onError('Syntax error: expected (');
        return false;
      }
    }

    if (string[string.length - 1].contains(RegExp(operations))) {
      if (onError != null) {
        onError(
            'Syntax error: Expected number/variable after ${string[string.length - 1]}');
      }
      return false;
    }

    while (string!.lastIndexOf('(') > -1) {
      var start = string.lastIndexOf('(') + 1;
      var end = string.substring(start).indexOf(')') + start;
      final error = _operationsCheck(string.substring(start, end));
      if (error != null) {
        if (onError != null) {
          onError(error);
          return false;
        }
      }
      string = string.replaceRange(start - 1, end + 1, '1');
    }

    final error = _operationsCheck(string);
    if (error != null) {
      if (onError != null) {
        onError(error);
        return false;
      }
    }
    return true;
  }
}
