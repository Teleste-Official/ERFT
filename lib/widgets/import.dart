import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/import.dart';
import '../models/polyline.dart';
import '../providers/function.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  Future<String?> importPath() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    return result?.files.single.path;
  }

  Future<String?> exportPath() async {
    return await FilePicker.platform.saveFile(
        type: FileType.custom,
        fileName: 'file.json',
        allowedExtensions: ['json']);
  }

  Future<File?> writeToFile(
      Map<String, dynamic> polyLine, Map<String, dynamic> functions) async {
    final path = await exportPath();
    if (path == null) return null;
    final file = File(path);
    final json = {...polyLine, ...functions};
    return file.writeAsString(jsonEncode(json));
  }

  @override
  Widget build(BuildContext context) {
    final polyline = context.watch<PolyLine>();
    final functions = context.watch<FunctionProvider>();
    final importProvider = context.read<Import>();

    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
              onPressed: () async {
                final path = await importPath();
                if (path == null) return;
                importProvider.load(path, (error) {
                  String? errorMessage;
                  if (error is PathNotFoundException) {
                    errorMessage = 'File not found.';
                  } else if (error is FormatException) {
                    errorMessage = 'File is not a valid json object.';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('Couldn\'t read from file: $errorMessage')));
                });
              },
              icon: const Icon(Icons.file_download),
              label: const Text('Import')),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
              onPressed: () async =>
                  writeToFile(polyline.toJson(), functions.toJson()),
              icon: const Icon(Icons.file_upload),
              label: const Text('Export')),
        )
      ],
    ));
  }
}
