import 'package:app_atex_gpt_exam/models/answer.dart';
import 'package:app_atex_gpt_exam/models/answer_aggregator.dart';
import 'package:app_atex_gpt_exam/models/exam.dart';
import 'package:app_atex_gpt_exam/models/question.dart';
import 'package:app_atex_gpt_exam/models/question_aggregator.dart';
import 'package:app_atex_gpt_exam/services/csv_reader_decoder.dart';
import 'package:app_atex_gpt_exam/services/database.dart';
import 'package:app_atex_gpt_exam/shared/isolate_manager.dart';
import 'package:app_atex_gpt_exam/shared/utilities.dart';
import 'package:flutter/material.dart';

class UploadExam extends StatefulWidget {
  const UploadExam({super.key, required this.userUID});
  final String userUID;

  @override
  State<UploadExam> createState() => _UploadExamState();
}

class _UploadExamState extends State<UploadExam> {

  ({String generatedExamUID, QuestionAggregator questionAggregator, List<AnswerAggregator> answerAggregatorList})? csvRecord;

  void acquireCsvList() async {

    var result = await CsvReaderDecoder().pickFile();  

    if (result != null) {
      setState(() {
        csvRecord = Utilities.generateLocalValuesFromDataCSV(data: result);
      });
    } else {
      print("[file_to_data, acquireCsvList]: No file selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: acquireCsvList , child: const Text("Pick File")),
              Padding(
                padding: EdgeInsets.all(40),
                child: SizedBox(
                  height: 400,
                  child: UploadStepper(userUID: widget.userUID,csvRecord: csvRecord)),
              ),
            ],
          )),
      ),
    );
  }
}


// stepper
class UploadStepper extends StatefulWidget {
  UploadStepper({super.key, required this.userUID, required this.csvRecord});
  final String userUID;

  ({String generatedExamUID, QuestionAggregator questionAggregator, List<AnswerAggregator> answerAggregatorList})? csvRecord;

  @override
  State<UploadStepper> createState() => _UploadStepperState();
}

class _UploadStepperState extends State<UploadStepper> {
  int _currentStep = 0;

  final examName = TextEditingController();
  final examDate = TextEditingController();
  final examCourse = TextEditingController();
  final examSubject = TextEditingController();
  
  void submitData() async {
    Exam? exam = Exam(
      date: examDate.text,
      name: examName.text,
      uid: widget.csvRecord!.generatedExamUID,
    );

    List<Future> futures = [];
    futures.add(DatabaseService().addExam(widget.userUID, exam));
    futures.add(DatabaseService().addQA(widget.csvRecord!.questionAggregator));
    for (AnswerAggregator aa in widget.csvRecord!.answerAggregatorList) {
      futures.add(DatabaseService().addAA(aa));
    }
    await Future.wait(futures);

    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        icon: Icon(Icons.warning),
        iconColor: Colors.blueAccent,
        title: Text("Em tese, seu arquivo foi salvo!"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("\nNa próxima dev version, conversaremos com o GPT!"),
          ],
        ),
      )
    );

    print("[file_to_data, submitData] calling initializeIsolate()");
    await IsolateManager().initializeIsolate();
    for (Question q in widget.csvRecord!.questionAggregator.questions) {
      for (Answer a in widget.csvRecord!.answerAggregatorList.firstWhere((aa) => aa.uid == q.answerAggregatorUID).answers) {
        print("[file_to_data, submitData] Enviando: ${q.questionBody} | ${a.studentAnswer}");
        IsolateManager().sendData((question: q, answer: a));
      }
    }
    
    // TODO: aqui eu vou redirecionar o usuário pra uma home da vida, e criar um Isolate (eu acho) pra ficar interagindo com o gpt AKA enviando as mensagens, esperando a resposta, e guardando o resultado no BD ao longo dessas operações.
    /*Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ),
    );*/
  }

  @override
  Widget build(BuildContext context) {
    if (widget.csvRecord != null) {
      return Stepper(
        currentStep: _currentStep,
        onStepTapped: (int newIndex) {
          setState(() {
            _currentStep = newIndex;
          });
        },
        onStepContinue: () {
          if (_currentStep < 1) {
            setState(() {
              _currentStep += 1;
            });
          } else {  // esse else significa que acabou os steps, agora é enviar essa bomba pro banco de dados e pro gpt
            submitData();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        type: StepperType.horizontal,
        steps: [
          Step(
            title: const Text("Exam Info"),
            isActive: _currentStep == 0,
            content: Column(
              children: [
                TextFormField(
                  controller: examName,
                  decoration: const InputDecoration(hintText: "Exam Name"),
                ),
                TextFormField(
                  controller: examDate,
                  decoration: const InputDecoration(hintText: "Exam Date"),
                ),
                TextFormField(
                  controller: examCourse,
                  decoration: const InputDecoration(hintText: "Exam Course"),
                ),
                TextFormField(
                  controller: examSubject,
                  decoration: const InputDecoration(hintText: "Exam Subject"),
                ),
              ],
            ),
          ),
          Step(
            isActive: _currentStep == 1,
            title: const Text("Questions and Answers"),
            content: Column(
              children: [
                for (Question q in widget.csvRecord!.questionAggregator.questions)
                  QuestionDataWidgetCompact(question: q, aa: widget.csvRecord!.answerAggregatorList.firstWhere((aa) => aa.uid == q.uid)),
              ],
            ),
          ),
        ],
      );
    } else {
      return const Placeholder();
    }
  }
}

class QuestionDataWidgetCompact extends StatelessWidget {
  const QuestionDataWidgetCompact({super.key, required this.question, required this.aa});

  final Question question;
  final AnswerAggregator aa;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("${question.questionBody}"),
        Container(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            children: [
              for (Answer a in aa.answers)
                Text("Student: ${a.studentUID} \n${a.studentAnswer}"),
            ],
          ),
        ),
      ],
    );
  }
}