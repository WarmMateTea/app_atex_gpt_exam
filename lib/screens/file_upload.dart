import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:convert' show utf8;

class FileUpload extends StatefulWidget {
  const FileUpload({super.key});

  @override
  State<FileUpload> createState() => _FileUploadState();
}

class _FileUploadState extends State<FileUpload> {

  FilePickerResult? currentFile; // ^ unused for now

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      final fileBytes = file.bytes;

      final dataUTF8 = utf8.decoder.convert(fileBytes!);
      //final data = String.fromCharCodes(fileBytes!);

      List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter(eol: '\n').convert(dataUTF8);
      
      print("===================================================");
      print("raw data after fromCharCodes: $dataUTF8");
      print("===================================================");
      print("list: $rowsAsListOfValues");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(onPressed: pickFile, child: const Text("Pick File")),
        ],
      ),
    );
  }
}
