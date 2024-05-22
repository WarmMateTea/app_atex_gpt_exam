// tags não usadas no momento
class Question {
  final String uid;

  Question({required this.uid, this.questionBody, this.gptAnswer}) {
    answerAggregatorUID = uid;
  }

  //Map? tags;
  String? questionBody;
  String? gptAnswer;
  //Map? studentAnswers;
  String? answerAggregatorUID;

  Question.fromJson(Map<String,dynamic> json)
  : 
  //tags = json['tags'] as Map,
  uid = json['uid'] as String,
  questionBody = (json['questionBody'] ?? "") as String,
  gptAnswer = (json['gptAnswer'] ?? "") as String,
  answerAggregatorUID = json['answerAggregatorUID'] as String;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'questionBody': questionBody,
      'gptAnswer': gptAnswer ?? '',
      'answerAggregatorUID': answerAggregatorUID ?? '',
    };
  }
}