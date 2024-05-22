import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

class CsvReaderDecoder {
  Future<List<List<dynamic>>?> pickFile() async {
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

      return rowsAsListOfValues;
    }
    return null;
  }
}