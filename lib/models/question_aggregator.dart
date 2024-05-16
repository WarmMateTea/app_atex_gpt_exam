import 'package:app_atex_gpt_exam/models/question.dart';

class QuestionAggregator {
  final String uid;
  final List<Question> questions;

  QuestionAggregator({required this.uid, required this.questions});

  QuestionAggregator.fromJson(Map<String, dynamic> json)
  : uid = json['uid'] as String,
     questions = (json['questions'] as List<dynamic>).map((q) => Question.fromJson(q)).toList();

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'questions': questions.map((question) => question.toJson()).toList(),
    };
  }
}