class Answer {
  final String uid;
  final String questionUID;
  final String studentUID;
  final String studentAnswer;
  
  Answer ({required this.uid, required this.questionUID, required this.studentUID, required this.studentAnswer, this.correctionGPT = "", this.rating = ""});

  String correctionGPT;
  String rating;

  Answer.fromJson(Map<String,dynamic> json)
  : uid = json['uid'],
    questionUID = json['questionUID'],
    studentUID = json['studentUID'],
    studentAnswer = json['studentAnswer'],
    correctionGPT = json['correctionGPT'],
    rating = json['rating'];
    //rating é criado quando eu interajo com o gpt, recebo a resposta dele e salvo ela

    Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'questionUID': questionUID,
      'studentUID': studentUID ?? "",
      'studentAnswer': studentAnswer ?? "",
      'correctionGPT': correctionGPT ?? "",
      'rating': rating ?? "",
    };
  }

  @override
  String toString() {
    String output = "";
    output += "AnswerUID: $uid";
    output += "QuestionUID: $questionUID";
    output += "StudentUID: $studentUID";
    output += "Student Answer: $studentAnswer";
    output += "GPT Correction: $correctionGPT";
    output += "Rating:: $rating";
    return output;
  }
}