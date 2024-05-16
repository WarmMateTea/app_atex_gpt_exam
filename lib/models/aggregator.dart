// ! TODO: DEPRECATED
class Aggregator {
  final String uid;
  final Map exams;

  Aggregator({required this.uid, required this.exams});

  Aggregator.fromJson(Map<String, dynamic> json,  this.uid)
    : exams = json['exams'] as Map;
}