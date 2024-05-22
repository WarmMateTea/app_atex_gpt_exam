import 'package:app_atex_gpt_exam/models/exam.dart';
import 'package:app_atex_gpt_exam/models/question.dart';

class QuestionAggregator {
  late String uid;
  final List<Question> questions;

  /// Recebe um Exam para puxar o UID dele (UID de um Exam e de um QuestionAggregator é o mesmo, sempre)
  QuestionAggregator({required Exam exam4uid, required this.questions}) {
    uid = exam4uid.uid;
  }

  QuestionAggregator.fromJson(Map<String, dynamic> json)
  : uid = (json['uid'] ?? "") as String,
     questions = ((json['questions'] ?? [] ) as List<dynamic>).map((q) => Question.fromJson(q)).toList();

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'questions': questions.map((question) => question.toJson()).toList(),
    };
  }
}