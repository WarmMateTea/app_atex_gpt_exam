import 'package:app_atex_gpt_exam/models/aggregator.dart';
import 'package:app_atex_gpt_exam/models/answer.dart';
import 'package:app_atex_gpt_exam/models/answer_aggregator.dart';
import 'package:app_atex_gpt_exam/models/appUser.dart';
import 'package:app_atex_gpt_exam/models/exam.dart';
import 'package:app_atex_gpt_exam/models/question.dart';
import 'package:app_atex_gpt_exam/models/question_aggregator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final String uid;
  DatabaseService({this.uid = ''});

  // & + nova
  /// Se supunheta que essa função recebe um QA todo fofo, apropriado, com o UID do seu Exam correspondente, com uma lista de Questions já bem estruturadinhas (ou vazia).
  /// AVISO: se já existir um QA com o UID especificado, ele será SOBRESCRITO.
  Future<void> addQA(QuestionAggregator qa) async {
    var qa_collection = FirebaseFirestore.instance.collection('questionAggregatorCollection');
    return await qa_collection.doc(qa.uid).set(qa.toJson());
  } 

  // & + nova
  /// Essa função assume receber um AA apropriado, com o UID da sua Question associada, com uma lista de Answers bem-estruturadas (ou vazia).
  /// AVISO: se já existir um QA com o UID especificado, ele será SOBRESCRITO.
  Future<void> addAA(AnswerAggregator aa) async {
    var aa_collection = FirebaseFirestore.instance.collection("answerAggregatorCollection");
    return await aa_collection.doc(aa.uid).set(aa.toJson());
  }

  // ! TODO: refatorar os métodos de adicionar Question e Answer.
  // ! motivo: como vc pode ter uma entrada de QA ou AA totalmente vazias (incluindo o UID), quando vc for adicionar um Question/Answer, caso o Aggregator correspondente "não exista" (AKA esteja vazio, AAKA UID vazia/nula), ele deverá ser criado apropriadamente. só então um UPDATE (no Aggregator) vai ter o efeito esperado. eu acho.
  // ! existe uma chance boa (vou testar isso PRIMEIRO) de, como os Aggregators serem documentos muito simples (UID + lista), que um aggregator "vazio" nunca chegue - talvez ele chegue somente com um UID (e uma lista vazia vinda do fromJSON), o que significa que adicionar a Question/Answer nessa lista e meter um update talvez funcione.

  // ^ Atualizada
  Future<AppUser?> fetchFullAppUser(String userUID) async {
    print("[database, fetchFullAppUser] DatabaseService: Tentando fetchFullAppUser para o userUID ${userUID}");
    var collection = FirebaseFirestore.instance.collection('appUserCollection');
    var userDoc = await collection.doc(userUID).get();
    print("[database, fetchFullAppUser] UserDoc retornado pela firebase: ${userDoc}");
    if (userDoc.exists) {
      print("[database, fetchFullAppUser] Conteúdo do Json recebido: ${userDoc.data()!}");
      AppUser user = AppUser.fromJson(userDoc.data() ?? {});
      print("[database, fetchFullAppUser] Json Convertido em User: ${user.toString()}");
      return user;
    } else {
      print("[database, fetchFullAppUser] Database Request fetchFullAppUser returned null at ${DateTime.now()}");
      return null;
    }
  }

  // ^ Atualizada
  Future<QuestionAggregator?> fetchQuestionAggregator(String questionAggregatorUID) async {
    var collection = FirebaseFirestore.instance.collection('questionAggregatorCollection');
    var questionAggregatorDoc = await collection.doc(questionAggregatorUID).get();
    if (questionAggregatorDoc.exists) {
      QuestionAggregator questionAggregator = QuestionAggregator.fromJson(questionAggregatorDoc.data()!);
      return questionAggregator;
    } else {
      return null;
    }
  }

  // ^ Atualizada
  Future<AnswerAggregator?> fetchAnswerAggregator(String answerAggregatorUID) async {
    print("fetchAnswerAggregator with UID $answerAggregatorUID");
    var collection = FirebaseFirestore.instance.collection('answerAggregatorCollection');
    var answerAggregatorDoc = await collection.doc(answerAggregatorUID).get();
    if (answerAggregatorDoc.exists) {
      AnswerAggregator answerAggregator = AnswerAggregator.fromJson(answerAggregatorDoc.data()!);
      return answerAggregator;
    } else {
      print("couldn't find answer aggregator with UID $answerAggregatorUID at ${DateTime.now()}");
      return null;
    }
  }
  
  // ^ Atualizada
  // salvar prova (direto no user)
  Future<Exam?> addExam(String userUID, Exam exam) async {
    var collection = FirebaseFirestore.instance.collection('appUserCollection');
    var userDoc = await collection.doc(userUID).get();
    if (userDoc.exists) {
      AppUser appUser = AppUser.fromJson(userDoc.data()!);
      appUser.exams.add(exam);
      collection.doc(userUID).update(appUser.toJson());
      return exam;
    } else {
      print("wtf addExam in database.dart couldn't find an app user of UID ${userUID}");
      return null;
    }
  }

  // ^ Atualizada	
  // salvar questões (fetch prova, se não tem questionaggregator (mesmo uid da prova), criar um e salvar questão nele)
  Future<Question?> addQuestion(String userUID, String examUID, Question question) async {
    var appUserCollection = FirebaseFirestore.instance.collection('appUserCollection');
    var questionAggregatorCollection = FirebaseFirestore.instance.collection('questionAggregatorCollection');
    var userDoc = await appUserCollection.doc(userUID).get();

    if (userDoc.exists) {
      AppUser appUser = AppUser.fromJson(userDoc.data()!);
      Exam exam = appUser.exams.firstWhere((ex) => ex.uid == examUID);
      // & dá pra jogar direto mas se não houver uid do QA no exam eu preciso atualizar de algum jeito
      // var qacol = FirebaseFirestore.instance.collection('questionAggregatorCollection');
      // var qaDoc = await qacol.doc(exam.examUID).get();

      // Caso: não tenho question aggregator para aquele exam
      if (exam.questionAggregatorUID == null || exam.questionAggregatorUID!.isEmpty) {
        QuestionAggregator qa = QuestionAggregator(
          //uid: "${exam.uid}" , 
          exam4uid: Exam(uid: examUID, name: "", date: ""),
          questions: [question],
        );
        // ! not working ?
        questionAggregatorCollection.doc(examUID).set(qa.toJson());
        DocumentReference? ref = questionAggregatorCollection.doc(examUID); // ! <- em TESE isso me traz uma referência ao documento que eu posso usar pra modificar ele IRT. 

        exam.questionAggregatorUID = ref.id;
        appUserCollection.doc(userUID).update(appUser.toJson());

        return question;
      } else { // Caso o question aggregator exista
        var qaDocRef = await questionAggregatorCollection.doc(exam.questionAggregatorUID).get();
        QuestionAggregator qa = QuestionAggregator.fromJson(qaDocRef.data()!);
        qa.questions.add(question);
        questionAggregatorCollection.doc(exam.questionAggregatorUID).update(qa.toJson());

        return question;
      }
    } else {
      print("wtf addQuestion in database.dart couldn't find an app user of UID ${userUID}");
      return null;
    }
  }

  // ^ Atualizada
  // salvar respostas (fetch questão, se não tem answeraggregator (mesmo uid da questão), criar um e salvar resposta nele)
  Future<Answer?> addAnswer(String userUID, String examUID, String questionUID, Answer answer) async {
    var questionAggregatorCollection = FirebaseFirestore.instance.collection('questionAggregatorCollection');
    var answerAggregatorCollection = FirebaseFirestore.instance.collection('answerAggregatorCollection');
    var qaDoc = await questionAggregatorCollection.doc(examUID).get();

    if (qaDoc.exists) {
      QuestionAggregator qa = QuestionAggregator.fromJson(qaDoc.data()!);
      Question question = qa.questions.firstWhere((q) => q.uid == questionUID);
      // Caso: não tenho answer aggregator para aquela questão
      if (question.answerAggregatorUID == null || question.answerAggregatorUID!.isEmpty) {
        AnswerAggregator aa = AnswerAggregator(
          //uid: "${question.uid}" , 
          question4uid: Question(uid: questionUID, questionBody: ""),
          answers: [answer]
        );

        answerAggregatorCollection.doc(aa.uid).set(aa.toJson());
        DocumentReference? ref = answerAggregatorCollection.doc(aa.uid);

        //salvar a atualização da question no qa (atualizando o QA todo)
        question.answerAggregatorUID = ref.id;
        questionAggregatorCollection.doc(examUID).update(qa.toJson()); //n sei se o update vai funcionar  


        return answer;
      } else { // Caso o answer aggregator exista
        var aaDocRef = await answerAggregatorCollection.doc(question.answerAggregatorUID).get();
        AnswerAggregator aa = AnswerAggregator.fromJson(aaDocRef.data()!);
        aa.answers.add(answer);
        answerAggregatorCollection.doc(question.answerAggregatorUID).update(aa.toJson());
        return answer;
      }
    } else {
      print("wtf addAnswer in database.dart couldn't find a question aggregator of UID ${examUID}");
      return null;
    }
  }

  // TODO
  //sem collection reference ela buga o .data lá embaixo

  // ok - aqui a gente trata da manipulação de coleções

  //puxar: 
  // searchables
  //tags[userUID]
   
  //disciplina[userUID]

  //curso[userUID]
  

  //aggregators[userUID]
  // listagem de avaliações: getAggregator[userUID] -> getExams[examUID]
  Future<Aggregator?> getAggregator(String userUID) async {
    var collection = FirebaseFirestore.instance.collection('aggregators');
    var userAggregatorDoc = await collection.doc(userUID).get();
    if (userAggregatorDoc.exists) {
      Aggregator userAggregator = Aggregator.fromJson(userAggregatorDoc.data()!, userAggregatorDoc.id);

      return userAggregator;
    } else {
      return null;
    }
  }

  //exams[userUID]
  Future<Exam?> getExam(String examUID) async {
    var collection = FirebaseFirestore.instance.collection('exams');
    var examDoc = await collection.doc(examUID).get();
    if (examDoc.exists) {
      Exam exam = Exam.fromJson(examDoc.data()!);
      return exam;
    } else {
      return null;
    }
  }

  //questions[userUID]
  // detalhes da avaliação (questões em alto nível): getQuestions[] / Exam.questions
  Future<List<Question?>> getQuestions(Map<String, String> questionUIDs) async {
    var collection = FirebaseFirestore.instance.collection('questions');
    List<Question> questions = List.empty();

    for (String questionUID in questionUIDs.keys) {
      var questionDoc = await collection.doc(questionUID).get();
      if (questionDoc.exists) {
        Question question = Question.fromJson(questionDoc.data()!);
        questions.add(question);
      }
    }
    return questions;
  }

  //answers[questionUID]
  // detalhes de uma questão X (resposta GPT + respostas dos alunos + correção GPT):getAnswers[] / Question.answers 
  Future<List<Answer?>> getAnswers(Map<String, String> answerUIDs) async {
    var collection = FirebaseFirestore.instance.collection('answers');
    List<Answer> answers = List.empty();
    
    for (String answerUID in answerUIDs.keys) {
      var answerDoc = await collection.doc(answerUID).get();
      if (answerDoc.exists) {
        Answer answer = Answer.fromJson(answerDoc.data()!);
        answers.add(answer);
      }
    }
    return answers;
  }

  //students.getAll()
  //


  // updateUserData
  Future updateUserData(String uid, String email, String nome, List<Exam>? exams) async {
    var collection = FirebaseFirestore.instance.collection('appUserCollection');
    print("DatabaseService tentando cadastrar o usuário:");
    print("UID: ${uid}");
    print("email: ${email}");
    print("nome: ${nome}");
    print("exams: ${exams}");
    return await collection.doc(uid).set({
      'uid': uid,
      'email': email,
      'name': nome,
      'exams': exams ?? List.empty(), // ! TODO: <- tem um jeito específico de fazer isso
      //'aggregatorUID': aggregatorUID.isEmpty ? getAggregator(uid) : aggregatorUID,
      //TODO: MAPA DOS SEARCHABLES
    });
  }
}

// requerimentos de cada tela
// home: nenhum



// cadastro manual de questão
// cadastro manual de usuário
// upload de arquivo para correção
// busca por questão (filtros: tag, curso, disciplina, data): getTags[userUID], getCourses[userUID], getSubjects[userUID], 