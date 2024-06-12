import 'dart:convert';

import 'package:app_atex_gpt_exam/models/answer.dart';
import 'package:app_atex_gpt_exam/models/question.dart';
import 'package:app_atex_gpt_exam/services/database.dart';
import 'package:app_atex_gpt_exam/shared/utilities.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SyncGPTRequest {
  static Future<Answer> singleRequest(Question q, Answer answerToReevaluate) async {
    print("[SyncGPTRequest, singleRequest]: started method");

    //request fofíssimo
    String prompt = """Você é um assistente de professor. Você receberá uma questão, e uma resposta de um estudante para essa questão. Avalie a resposta brevemente quanto à precisão e se ela contemplou tudo o que a questão pedia. Ao final, insira uma avaliação, indo de 0 a 100%, entre colchetes, assim: [X%], onde X é a avaliação.
    Questão: ${q.questionBody}
    Resposta do estudante: ${answerToReevaluate.studentAnswer}
    Sua avaliação:""";

    var url = Uri.parse('https://api.openai.com/v1/chat/completions');
    
    var apiKey = dotenv.env['OPENAI_API_KEY'];

    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        "messages": [{
          "role": "user", "content": prompt
        }]
      }),
    );

    print("[SyncGPTRequest, singleRequest]: http request finished");

    var responseBody = utf8.decode(response.bodyBytes);
    var decodedBody = jsonDecode(responseBody);
    var answer = decodedBody['choices'][0]['message']['content'];

    answerToReevaluate.correctionGPT = answer;
    answerToReevaluate.rating = Utilities.extractRatingFromCorrection(input: answer);

    print("[SyncGPTRequest, singleRequest]: updating db");

    // atualizar a entrada de dados na DB
    DatabaseService().updateAnswer(answerToReevaluate, q.answerAggregatorUID!);

    print("[SyncGPTRequest, singleRequest]: done");

    return answerToReevaluate;
  }
}