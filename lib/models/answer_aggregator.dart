import 'package:app_atex_gpt_exam/models/answer.dart';

class AnswerAggregator {
  final String uid;

  List<Answer> answers;

  AnswerAggregator({required this.uid, required this.answers});

  AnswerAggregator.fromJson(Map<String, dynamic> json)
  : uid = json['uid'],
    answers = (json['answers'] as List<dynamic>).map((a) => Answer.fromJson(a)).toList();

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }
}