import 'dart:math';

import 'package:app_atex_gpt_exam/models/answer.dart';
import 'package:app_atex_gpt_exam/models/answer_aggregator.dart';
import 'package:app_atex_gpt_exam/models/appUser.dart';
import 'package:app_atex_gpt_exam/models/exam.dart';
import 'package:app_atex_gpt_exam/models/question.dart';
import 'package:app_atex_gpt_exam/models/question_aggregator.dart';
import 'package:app_atex_gpt_exam/screens/chat.dart';
import 'package:app_atex_gpt_exam/screens/chat_interaction/file_to_data.dart';
import 'package:app_atex_gpt_exam/screens/file_upload.dart';
import 'package:app_atex_gpt_exam/screens/home/explorer.dart';
import 'package:app_atex_gpt_exam/services/auth.dart';
import 'package:app_atex_gpt_exam/services/database.dart';
import 'package:app_atex_gpt_exam/shared/constants.dart';
import 'package:app_atex_gpt_exam/shared/utilities.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  Home({super.key, required this.appUser});

  final AppUser appUser;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  late Future<AppUser?> _userDataFuture;
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _userDataFuture = DatabaseService().fetchFullAppUser(widget.appUser.uid);
  }

  Future<void> _refreshData() async {
    setState(() {
      _userDataFuture = DatabaseService().fetchFullAppUser(widget.appUser.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: FutureBuilder(
        future: _userDataFuture,
        builder: (context, snapshot) {
          print("[home, build] conteúdo snapshot: ${snapshot.data}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            AppUser finalAppUser = snapshot.data!;
            //return TestingHome(appUser: finalAppUser);
            //return ChatHome();
            //return FileUpload();
            //return UploadExam(userUID: widget.appUser.uid);
            return ExplorerBase(userCompleto: snapshot.data!);
          }
        },
      ),
    );
  }
}

class TestingHome extends StatefulWidget {
  const TestingHome({super.key, required this.appUser});
  final AppUser appUser;

  @override
  State<TestingHome> createState() => _TestingHomeState();
}

class _TestingHomeState extends State<TestingHome> {
  @override
  Widget build(BuildContext context) {

    void _showRegisterPanel() {
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
          child: ManualSingularRegisterForm(appUser: widget.appUser),
        )
      );
    }

    AppUser appUser = widget.appUser;

    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showRegisterPanel();
              });
            },
            icon: const Icon(Icons.add),
            label: const Text("Cadastrar uma nova árvore"),
          )
        ],
      ),
      body: ListView(
        children: [
          Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'User Data', 
              style: TextStyle(fontSize: 20),
            ),
            TextFormField(
              decoration: textInputDecoration.copyWith(hintText: 'userUID'),
              initialValue: appUser.uid,
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: textInputDecoration.copyWith(hintText: 'user email'),
              initialValue: appUser.email,
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: textInputDecoration.copyWith(hintText: 'user name'),
              initialValue: appUser.name,
            ),
            const SizedBox(height: 40),
            for (Exam e in appUser.exams)
              ExamDataWidget(exam: e),
            
          ]
        ),
        ],      
      ),
    );
  }
}

// nota: aggregatorUID provavelmente será o userUID pq ele é único por usuário, potencialmente tornando-o redundante
class ExamDataWidget extends StatelessWidget {
  const ExamDataWidget({super.key, required this.exam});
  final Exam exam;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Exam', 
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: textInputDecoration.copyWith(hintText: 'Exam Name'),
          initialValue: exam.name,
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: textInputDecoration.copyWith(hintText: 'Exam Date'),
          initialValue: exam.date,
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: textInputDecoration.copyWith(hintText: 'Queston Aggregator UID'),
          initialValue: exam.questionAggregatorUID,
        ),
        QuestionAggregatorWidget(questionAggregatorUID: exam.questionAggregatorUID ?? ""),
        const SizedBox(height: 40),
      ]
    );
  }
}

class QuestionAggregatorWidget extends StatelessWidget {
  const QuestionAggregatorWidget({super.key, required this.questionAggregatorUID});
  final String questionAggregatorUID;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseService().fetchQuestionAggregator(questionAggregatorUID), 
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          QuestionAggregator? questionAggregator = snapshot.data;
          return Column(
            children: [
              for (Question q in questionAggregator!.questions)
                QuestionDataWidget(question: q),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      });
  }
}

class QuestionDataWidget extends StatelessWidget {
  const QuestionDataWidget({super.key, required this.question});
  final Question question;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Question UID: ${question.uid}"),
                Text("Answer Aggregator UID: ${question.answerAggregatorUID}"),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Question Body: ${question.questionBody}"),
                Text("GPT Answer: ${question.gptAnswer}"),
              ],
            ),
          ],
        ),
        AnswerAggregatorWidget(answerAggregatorUID: question.answerAggregatorUID ?? ""),
      ],
    );
  }
}

class AnswerAggregatorWidget extends StatelessWidget {
  const AnswerAggregatorWidget({super.key, required this.answerAggregatorUID});
  final String answerAggregatorUID;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
    future: DatabaseService().fetchAnswerAggregator(answerAggregatorUID), 
    builder: (context, snapshot) {
        if (snapshot.hasData) {
          AnswerAggregator? answerAggregator = snapshot.data;
          return Column(
            children: [
              for (Answer a in answerAggregator!.answers)
                AnswerDataWidget(answer: a),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      });
  }
}

class AnswerDataWidget extends StatelessWidget {
  const AnswerDataWidget({super.key, required this.answer});
  final Answer answer;

  @override
  Widget build(BuildContext context) {

    print("Answer shown:\n" + answer.toString());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Answer UID: ${answer.uid}"),
            Text("Question UID: ${answer.questionUID}"),
            Text("Student UID: ${answer.studentUID}"),
          ]
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Student Answer: ${answer.studentAnswer}"),
            Text("GPT's Correction: ${answer.correctionGPT}"),
            Text("GPT's Rating: ${answer.rating}"),
          ]
        ),
      ]
    );
  }
}

// ! ^^^^ pensar num jeito de jogar esse processamento das questões numa thread separada quando eu as estiver inserindo. como essa parte, no momento, é só uma exibição, não vou me preocupar agora.

// cadastro manual de prova + questão

class CustomInput extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String? hint;
  final InputBorder? inputBorder;
  final TextEditingController controller;
  const CustomInput({super.key, this.onChanged, this.hint, this.inputBorder, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom:10),
      child: TextFormField(
        onChanged: null,//(v) => onChanged!(v),
        decoration: InputDecoration(hintText: hint!, border: inputBorder),
        controller: controller,
      ),
    );
  }
}

class ManualSingularRegisterForm extends StatefulWidget {
  const ManualSingularRegisterForm({super.key, required this.appUser});

  final AppUser appUser;

  @override
  State<ManualSingularRegisterForm> createState() => _ManualSingularRegisterFormState();
}

class _ManualSingularRegisterFormState extends State<ManualSingularRegisterForm> {
  int currentStep = 0;

  final examName = TextEditingController();
  final examDate = TextEditingController();
  final examCourse = TextEditingController();
  final examSubject = TextEditingController();
  final questionBody = TextEditingController();
  final studentName = TextEditingController();
  final studentAnswer = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stepper(
      type: StepperType.horizontal,
      currentStep: currentStep,
      onStepCancel: () => currentStep == 0 
      ? null
      : setState((){
        currentStep -= 1;
      }),
      onStepContinue: () async {
        bool isLastStep = (currentStep == getSteps().length - 1);
        if (isLastStep) {
          // acabou o form, hora de montar a estrutura de dados e enviar
          
          print("trying to register exam");
          Exam? exam = Exam(
            date: DateTime.now().toString(),
            name: examName.text,
            uid: Utilities.generateExamUID(), // <- exam não tem UID verdadeiro então tô usando isso pra suprir a causa
          );
          print("this should be registered: ${exam.toString()}");
          exam = await DatabaseService().addExam(widget.appUser.uid, exam);
          print("done registering exam");

          print("trying to register question");
          Question? question = Question(
            questionBody: questionBody.text,
            uid: Utilities.generateQuestionUID(), // <- mesma ideia do exam aqui no uid da question
          );
          print("this should be registered: ${question.toString()}");
          question = await DatabaseService().addQuestion(widget.appUser.uid, exam!.uid, question);
          print("done registering question");
          
          print("trying to register answer");
          Answer? answer = Answer(
            studentUID: studentName.text,
            questionUID: question!.uid,
            studentAnswer: studentAnswer.text,
            uid: Utilities.generateAnswerUID(), // <- mesma ideia do exam e da question aqui no uid da answer
          );
          print("this should be registered: ${answer.toString()}");
          answer = await DatabaseService().addAnswer(widget.appUser.uid, exam.uid, question.uid, answer);
          print("done registering answer");

          if (mounted) Navigator.pop(context);

        } else {
          setState(() {
            currentStep += 1;
          });
        }
      },
      onStepTapped: (step) => setState(() => currentStep = step),
      steps: getSteps(),
    );
  }

  List<Step> getSteps() {
    return <Step>[
      Step( //cadastrar a prova
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 0,
        title: const Text("Exam Info"),
        content: Column(
          children: [
            CustomInput(
            hint: "Exam Name",
            inputBorder: const OutlineInputBorder(),
            controller: examName,
            ),
            CustomInput(
              hint: "Exam Date",
              inputBorder: const OutlineInputBorder(),
              controller: examDate,
            ),
            CustomInput(
              hint: "Exam Course",
              inputBorder: const OutlineInputBorder(),
              controller: examCourse,
            ),
            CustomInput(
              hint: "Exam Subject",
              inputBorder: const OutlineInputBorder(),
              controller: examSubject,
            ),
          ]
        ),
      ),
      Step( //cadastrar uma questão
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: const Text("Question Info"),
        content: Column(
          children: [
            CustomInput(
            hint: "Question Body",
            inputBorder: const OutlineInputBorder(),
            controller: questionBody,
            ),
          ]
        )
      ),
      Step( //cadastrar uma resposta para essa questão
        state: currentStep > 2 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 2,
        title: const Text("Answer Info"),
        content: Column(
          children: [
            CustomInput(
            hint: "Student Name",
            inputBorder: const OutlineInputBorder(),
            controller: studentName,
            ),
            CustomInput(
              hint: "Student Answer",
              inputBorder: const OutlineInputBorder(),
              controller: studentAnswer,
            ),
          ]
        )
      ),
    ];
  }
}

