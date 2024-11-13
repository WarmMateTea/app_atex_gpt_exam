
import 'package:app_atex_gpt_exam/services/csv_reader_decoder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileUpload extends StatefulWidget {
  const FileUpload({super.key});

  @override
  State<FileUpload> createState() => _FileUploadState();
}

class _FileUploadState extends State<FileUpload> {

  FilePickerResult? currentFile; // ^ unused for now

  void acquireCsvList() {
    var result = CsvReaderDecoder().pickFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(onPressed: acquireCsvList , child: const Text("Pick File")),
        ],
      ),
    );
  }
}
