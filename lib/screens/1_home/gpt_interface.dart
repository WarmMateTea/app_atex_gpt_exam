import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

String apiKey = dotenv.env['OPENAI_API_KEY']!;

class GptInterfaceCreateQuestion {
  static Future<String> generateQuestion(QuestionRequest obj) async {
    String guidancePrompt =
    """Você é um assistente de professor. Você deverá elaborar uma questão, de nível universitário, de acordo com os parâmetros fornecidos pelo usuário.""";

    String prompt = 
    """Tipo de Questão: ${obj.isDiscursive ? 'Discursiva' : 'Objetiva com 5 alternativas'};
    Área da Questão: ${obj.areaAndCourse};
    Tema da Questão: ${obj.data};
    ${obj.isDiscursive ? 'Forneça também um exemplo de resposta adequada, para nortear a correção.' : 'Forneça também a resposta correta, e explique porque ela está correta e as outras estão erradas.'}
    ${obj.considerBloom ? 'Atenção: Ao elaborar a questão, faça-a de modo a considerar a Taxonomia de Bloom, e explique como a questão verifica os três níveis dessa Taxonomia.' : ''}""";


    Uri url = Uri.parse('https://api.openai.com/v1/chat/completions');
    OpenAiApiRequest request = OpenAiApiRequest(url: url, guidancePrompt: guidancePrompt, prompt: prompt);
    var answerObj = await request.getAnswer();
    String answer = answerObj['choices'][0]['message']['content'];
    
    return answer;
  }
}

class QuestionRequest {
  QuestionRequest({
    this.output = '', 
    required this.data, 
    required this.isDiscursive, 
    required this.areaAndCourse, 
    required this.considerBloom});

  String output;
  final String areaAndCourse;
  final String data;
  final bool isDiscursive;
  final bool considerBloom;
}

class OpenAiApiRequest {
  OpenAiApiRequest({
    required this.url,
    required this.guidancePrompt,
    required this.prompt
  });

  final Uri url;
  final String guidancePrompt;
  final String prompt;

  Future<dynamic> getAnswer() async {
    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        "messages": [
          {"role": "system", "content": guidancePrompt},
          {"role": "user", "content": prompt}
        ]
      }),
    );

    var responseBody = utf8.decode(response.bodyBytes);
    return jsonDecode(responseBody);
  }
}