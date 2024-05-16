import 'package:app_atex_gpt_exam/models/exam.dart';

class AppUser {
  final String uid;
  late String email;

  AppUser({required this.uid, required this.email, this.name = "", this.exams = const []});

  String name;
  List<Exam> exams;
  //late String aggregatorUID;
  //late Map searchables;

  AppUser.fromJson(Map<String,dynamic> json)
  : uid = json['uid'] as String,
    name = json['name'] as String,
    email = json['email'] as String,
    exams = (json['exams'] as List<dynamic>).map((e) => Exam.fromJson(e)).toList();

  @override
  String toString() {
    return "App User {\nuid: $uid,\nemail: $email,\nname: $name,\nexams: $exams,\n}";
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'exams': exams.map((exam) => exam.toJson()).toList(),
    };
  }

}