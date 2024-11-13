import 'package:app_atex_gpt_exam/models/appUser.dart';
import 'package:app_atex_gpt_exam/screens/2_upload_exam/file_to_data.dart';
import 'package:app_atex_gpt_exam/screens/4_create_question/create_question_page.dart';
import 'package:app_atex_gpt_exam/screens/3_explore_questions/explorer.dart';
import 'package:app_atex_gpt_exam/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

const textInputDecoration = InputDecoration(
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(width: 2.0),
  )
);

var lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light
    ),
    textTheme: GoogleFonts.jostTextTheme(),
  );

var darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
  textTheme: GoogleFonts.jostTextTheme(),
);

class ThemeModel extends ChangeNotifier {
  ThemeData currentTheme = lightTheme;
  bool isDarkMode = false;

  toggleTheme() {
    isDarkMode = !isDarkMode;
    currentTheme = isDarkMode ? lightTheme : darkTheme;
    return notifyListeners();
  }
}

enum bottomAppBarSelected { upload, explorer, create }

class Defaults {
  static InputDecoration getDefaultTextInputDeco({
    required TextEditingController controller,
    dynamic icon = Icons.search,
    bool clearButton = false,
    String labelText = "Label Text",
    String hintText = "Hint Text",
  }) {
    return InputDecoration(
      prefixIcon: Icon(Icons.search),
      suffixIcon: (clearButton) ? _clearButton(controller: controller) : null,
      labelText: labelText,
      hintText: hintText,
      border: const OutlineInputBorder(),
    );
  }

  static Widget _clearButton({required TextEditingController controller}) {
    return IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        controller.clear();
      },
    );
  }
}