import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AiType { ChatGPT, Gemini }

class WhichAi {
  // Coisas de classe singleton
  static WhichAi? _instance;
  static WhichAi get instance {
    return _instance ??= WhichAi._();
  }

  // Construtor. Quando a classe é criada, se não houver uma chave Gemini cadastrada, uma predefinida será usada para propostas de demonstração.
  WhichAi._() {
    _selectedAiType = AiType.Gemini;
    getApiKey().then((key) {
      if (key == null || key.isEmpty) {
        // Gemini Key
        saveApiKey("AIzaSyB-nZK9TmhhjafWZkezQ5JXQXG0tgvNz8s", AiType.Gemini);
      }
    });
  }

  // Dados úteis da classe
  AiType _selectedAiType = AiType.Gemini;
  int _counter = 0;

  AiType getAiType() {
    return _selectedAiType;
  }

  AiType toggleAiType() {
    _counter++;
    print('counter: $_counter');
    print('before: $_selectedAiType');
    if (_selectedAiType == AiType.Gemini) {
      _selectedAiType = AiType.ChatGPT;
    } else {
      _selectedAiType = AiType.Gemini;
    }
    print('after: $_selectedAiType');
    return _selectedAiType;
  }

  Color getAiBgColor() {
    switch (_selectedAiType) {
      case AiType.Gemini:
        return const Color.fromARGB(255, 0, 0, 0);
      case AiType.ChatGPT:
        return const Color.fromARGB(255, 117, 172, 157);
    }
  }

  Widget getAiIcon() {
    switch (_selectedAiType) {
      case AiType.Gemini:
        return Image.asset('lib/assets/gemini.png', width: 24, height: 24,);
      case AiType.ChatGPT:
        return SvgPicture.asset('lib/assets/chatgpt.svg', colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn), width: 24, height: 24);
    }
  }

  Future<void> saveApiKey(String apiKey, AiType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${type.name}_api_key', apiKey);
  }

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${_selectedAiType.name}_api_key') ?? '';
  }
}