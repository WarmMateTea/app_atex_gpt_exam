class Exam {
  final String uid; // <- não tem um UID
  final String name;
  final String date;

  Exam({required this.uid, required this.name, required this.date});

  String? courseUID;
  String? subjectUID;
  String? questionAggregatorUID; //Map? questions;

  Exam.fromJson(Map<String,dynamic> json)
  : uid = (json['uid'] ?? "") as String,
    name = (json['name'] ?? "") as String,
    date = (json['date'] ?? "") as String,
    courseUID = (json['courseUID'] ?? "") as String,
    subjectUID = (json['subjectUID'] ?? "") as String,
    questionAggregatorUID = (json['questionAggregatorUID'] ?? "") as String;
    
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'date': date,
      'courseUID': courseUID,
      'subjectUID': subjectUID,
      'questionAggregatorUID': questionAggregatorUID,
    };
  }

}