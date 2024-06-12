import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:app_atex_gpt_exam/services/database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:app_atex_gpt_exam/models/answer.dart';
import 'package:app_atex_gpt_exam/models/question.dart';

/// Classe que interage com o ChatGPT.
/// Como ela fica sempre rodando de fundo, ela é um Singleton.
/// Acho que ela nunca vai ser morta, e se for ela nunca mais vive até resetar o app.
/// A parte exposta da classe é o sendData, que recebe um Record ({Question question, Answer? answer}) e os envia para o isolate.
class IsolateManager {
  static final IsolateManager _singleton = IsolateManager._internal();
  factory IsolateManager() {
    return _singleton;
  }

  IsolateManager._internal();

  final _dataQueue =
      StreamController<({Question question, Answer? answer})>.broadcast();
  final _messageMap = <int, ({String questionUID, String? answerUID})>{};
  int _messageIdCounter = 0;

  Future<void> initializeIsolate() async {
    final envContent = await rootBundle.loadString('.env');
    await dotenv.load(
        fileName: ".env"); // TODO MANO WTF ESSE COISO N QUER FUNCIONAR
    final receivePort = ReceivePort();
    await Isolate.spawn(_isolateEntryPoint, receivePort.sendPort);
    final sendPort = await receivePort.first;

    print("[IsolateManager, initializeIsolate] adding listener to _dataQueue}");
    _dataQueue.stream.listen((data) {
      print("[IsolateManager, listening] oh hey new data: ${data.toString()}");
      final id = _messageIdCounter++;

      _messageMap[id] =
          (questionUID: data.question.uid, answerUID: data.answer?.uid);
      sendPort.send({'id': id, 'data': data});
    });
    print(
        "[IsolateManager, initializeIsolate] done adding listener to _dataQueue}");
  }

  void sendData(({Question question, Answer? answer}) questionAnswerRecord) {
    print(
        "[IsolateManager, sendData] received new data: ${questionAnswerRecord.question.questionBody} | ${questionAnswerRecord.answer?.studentAnswer}");
    _dataQueue.add(questionAnswerRecord);
    print(
        "[IsolateManager, sendData] does _dataQueue have a listener: ${_dataQueue.hasListener}");
  }

  static void _isolateEntryPoint(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) async {
      print(
          "[IsolateManager, _isolateEntryPoint, listening] received message: ${message.toString()}");
      final id = message['id'];
      final data = message['data'];

      if (data is ({Question question, Answer? answer})) {
        if (data.answer != null) {
          // Interação com o chat
          String prompt =
              """Você é um assistente de professor. Você receberá uma questão, e uma resposta de um estudante para essa questão. Avalie a resposta brevemente quanto à precisão e se ela contemplou tudo o que a questão pedia. Ao final, insira uma avaliação, indo de 0 a 100%, entre colchetes.
          Questão: ${data.question.questionBody}
          Resposta do estudante: ${data.answer?.studentAnswer}
          Sua avaliação:""";

          var url = Uri.parse('https://api.openai.com/v1/chat/completions');
          var apiKey = dotenv.env['OPEN_AI_KEY'];
          // var apiKey = dotenv // note que se vc tentar dar commit com a chave exposta o git explode e vc tera um problemão nas mãos :pray_emoji:

          print(
              "[IsolateManager, _isolateEntryPoint, listening] sending http request for prompt: ${prompt}");
          var response = await http.post(
            url,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'gpt-3.5-turbo',
              "messages": [
                {"role": "user", "content": prompt}
              ]
            }),
          );

          var decodedBody = jsonDecode(response.body);
          print(decodedBody);

          // TODO: salvar no DB
          var answer = decodedBody['choices'][0]['message']['content'];
          //DatabaseService().updateAnswer(data.answer!);
        } else {
          // TODO:...rapaz
        }
      }

      // task moment
      sendPort.send(id);
    });
  }
}
