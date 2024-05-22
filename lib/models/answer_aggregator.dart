import 'package:app_atex_gpt_exam/models/answer.dart';
import 'package:app_atex_gpt_exam/models/question.dart';

class AnswerAggregator {
  late String uid;

  List<Answer> answers;

  /// Recebe um Question para puxar o UID dele (UID de um Question e de um AnswerAggregator é o mesmo, sempre)
  AnswerAggregator({required Question question4uid, required this.answers}) {
    uid = question4uid.uid;
  }

  AnswerAggregator.fromJson(Map<String, dynamic> json)
  : uid = (json['uid'] ?? ""),
    answers = ((json['answers'] ?? [] ) as List<dynamic>).map((a) => Answer.fromJson(a)).toList();

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }
}