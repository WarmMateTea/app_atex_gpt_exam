import 'dart:math';
import 'package:app_atex_gpt_exam/models/answer.dart';
import 'package:app_atex_gpt_exam/models/answer_aggregator.dart';
import 'package:app_atex_gpt_exam/models/exam.dart';
import 'package:app_atex_gpt_exam/models/question.dart';
import 'package:app_atex_gpt_exam/models/question_aggregator.dart';

/// infinite say gex
class Utilities {
  static String generateExamUID() {
    return "${DateTime.now().toString()}_${Random().nextInt(999)}.${Random().nextInt(999)}.${Random().nextInt(999)}.${Random().nextInt(999)}";
  }

  static String generateQuestionUID() {
    return generateExamUID();
  } 

  static String generateAnswerUID() {
    return generateExamUID();
  }

  static ({String generatedExamUID, QuestionAggregator questionAggregator, List<AnswerAggregator> answerAggregatorList}) generateLocalValuesFromDataCSV({required List<List<dynamic>> data, bool hasNameColumn = false}) {

    String generatedExamUID = generateExamUID();

    List<Question> questionList = List.empty(growable: true); // usado só para armazenar as questões em uma lista que depois é passada ao QA no construtor
    QuestionAggregator questionAggregator;
    List<AnswerAggregator> answerAggregatorList = List.empty(growable: true);


    if (hasNameColumn) {
      print("[utilities, generateLocalValuesFromDataCSV]: hasNameColumn not implemented yet");
    }
    
    // Loop por cada pergunta (coluna) da matriz data[][]
    for (int i = 2; i < data[0].length; i++) {
      print("[utilities, generateLocalValuesFromDataCSV]: ===================================================");
      print("[utilities, generateLocalValuesFromDataCSV]: Question Title: ${data[0][i]}");

      // UID da pergunta processada no momento
      String currentQuestionUID = generateQuestionUID();
      // Lista de respostas da pergunta processada
      List<Answer> currentAnswerList = List.empty(growable: true);

      // Para cada pergunta, gerar a resposta e já bindar os UIDs
      for (int j = 1; j < data.length; j++) {
        print("[utilities, generateLocalValuesFromDataCSV]: Answer (${data[j][1]}): ${data[j][i]}");

        // Adicionar a resposta na lista de respostas da pergunta sendo processada
        currentAnswerList.add(
          Answer(
            questionUID: currentQuestionUID, 
            uid: generateAnswerUID(),
            studentAnswer: data[j][i], 
            studentUID: data[j][0]
            )
          );
      }

      // Gerar o agregador de respostas e adicioná-lo na lista de agregadores de resposta (um pra cada questão)
      answerAggregatorList.add(
        AnswerAggregator(
          question4uid: Question( // essa question é redundante - ela só representa um UID. Mas deixa ela aí.
            uid: currentQuestionUID, 
            questionBody: data[0][i]
          ),
          answers: currentAnswerList,
        ),
      );

      //adicionando a questão na lista de questões
      questionList.add(Question(questionBody: data[0][i], uid: currentQuestionUID));
    }
    
    // Gerando o Question Aggregator para essa prova
    questionAggregator = QuestionAggregator(
      exam4uid: Exam(uid: generatedExamUID, name: "", date: ""),  // esse exam é redundante e só serve para representar um UID. O exam de verdade vai ser criado mais tarde, fora desse método (e dessa classe).
      questions: questionList
    );

    return (
      generatedExamUID: generatedExamUID,
      questionAggregator: questionAggregator,
      answerAggregatorList: answerAggregatorList
    );
  }

  static String extractRatingFromCorrection({required String input}) {
  // Define a expressão regular para encontrar a substring entre colchetes.
  RegExp regex = RegExp(r'\[(.*?)\]');
  
  // Tenta encontrar a substring que corresponda à expressão regular.
  Match? match = regex.firstMatch(input);
  
  // Variável para armazenar o resultado.
  String resultado = '0%';
  
  // Se encontrar um match, extrai a substring.
  if (match != null) {
    // Extrai a substring.
    String? substring = match.group(1);
    
    // Verifica se a substring é válida.
    if (substring != null) {
      // Remove a palavra "Avaliação: " se estiver presente.
      substring = substring.replaceAll('Avaliação: ', '');
      
      // Define o resultado como a substring extraída.
      resultado = substring;
    }
  }
  
  return resultado;
}
}