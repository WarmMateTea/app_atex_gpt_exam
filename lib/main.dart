import 'package:app_atex_gpt_exam/models/appUser.dart';
import 'package:app_atex_gpt_exam/screens/1_home/wrapper.dart';
import 'package:app_atex_gpt_exam/services/auth.dart';
import 'package:app_atex_gpt_exam/shared/constants.dart';
import 'package:app_atex_gpt_exam/shared/isolate_manager.dart';
import 'package:app_atex_gpt_exam/shared/which_ai.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  //IsolateManager.setApiKeyGpt(key: dotenv.env['OPENAI_API_KEY']!);
  IsolateManager.setApiKeyGpt(key: (await WhichAi.instance.getApiKey())!);
  runApp(
    ChangeNotifierProvider<ThemeModel>(
      create: (context) => ThemeModel(),
      child: const MainApp(),
      )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<AppUser?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        title: 'GPT Exam',
        theme: FlexThemeData.light(scheme: FlexScheme.amber, fontFamily: GoogleFonts.jost().fontFamily), // Provider.of<ThemeModel>(context).currentTheme,
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.amber, fontFamily: GoogleFonts.jost().fontFamily), // TODO toggle thememode? change font family? hmmm....
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const Wrapper(),
      ),
    );
  }
}
