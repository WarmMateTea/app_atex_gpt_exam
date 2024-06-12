import 'package:app_atex_gpt_exam/models/answer.dart';
import 'package:app_atex_gpt_exam/models/answer_aggregator.dart';
import 'package:app_atex_gpt_exam/models/exam.dart';
import 'package:app_atex_gpt_exam/models/question.dart';
import 'package:app_atex_gpt_exam/models/question_aggregator.dart';
import 'package:app_atex_gpt_exam/services/auth.dart';
import 'package:app_atex_gpt_exam/services/csv_reader_decoder.dart';
import 'package:app_atex_gpt_exam/services/database.dart';
import 'package:app_atex_gpt_exam/shared/isolate_manager.dart';
import 'package:app_atex_gpt_exam/shared/utilities.dart';
import 'package:flutter/material.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_atex_gpt_exam/screens/widgets/input_field.dart';

class UploadExam extends StatefulWidget {
  const UploadExam({super.key, required this.userUID});
  final String userUID;

  @override
  State<UploadExam> createState() => _UploadExamState();
}

class _UploadExamState extends State<UploadExam> {
  ({
    String generatedExamUID,
    QuestionAggregator questionAggregator,
    List<AnswerAggregator> answerAggregatorList
  })? csvRecord;

  void acquireCsvList() async {
    //var status = await Permission.manageExternalStorage.request();
    //  if (status.isDenied) {
    //    print("storage perms denied");
    //    // We haven't asked for permission yet or the permission has been denied before, but not permanently.
    // //  }
    // final mediaStorePlugin = MediaStore();
    // List<Permission> permissions = [
    //   Permission.storage,
    // ];
    // await permissions.request();
    // print((await mediaStorePlugin.getFilePathFromUri(uriString: 'content://media/external_primary/images/media/1000000057')));

    var result = await CsvReaderDecoder().pickFile();

    if (result != null) {
      setState(() {
        csvRecord = Utilities.generateLocalValuesFromDataCSV(data: result);
      });
    } else {
      print("[file_to_data, acquireCsvList]: No file selected");
    }
  }

  Future<bool?> showConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false when No is pressed
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true when Yes is pressed
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue[800],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: () {
                print('?');
              },
              icon: const Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: 40,
              ),
            ),
            IconButton(
              onPressed: () {
                print('Home');
              },
              icon: const Icon(
                Icons.home,
                color: Colors.white,
                size: 40,
              ),
            ),
            IconButton(
              onPressed: () {
                bool? shouldSignOut = await showConfirmationDialog(context);
                AuthService().signOut();
              },
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(40),
                  child: SizedBox(
                      height: 400,
                      child: UploadStepper(
                          userUID: widget.userUID, csvRecord: csvRecord)),
                ),
                Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    shape: const StadiumBorder(),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade600,
                        Colors.blue.shade900,
                      ],
                    ),
                  ),
                  child: TextButton(
                    style: const ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                    ),
                    onPressed: () {
                      acquireCsvList();
                    },
                    child: const Text(
                      "Escolher arquivo",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
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

  ({
    String generatedExamUID,
    QuestionAggregator questionAggregator,
    List<AnswerAggregator> answerAggregatorList
  })? csvRecord;

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
            ));

    await IsolateManager().initializeIsolate();
    for (Question q in widget.csvRecord!.questionAggregator.questions) {
      for (Answer a in widget.csvRecord!.answerAggregatorList
          .firstWhere((aa) => aa.uid == q.answerAggregatorUID)
          .answers) {
        print(
            "[file_to_data, submitData] Enviando: ${q.questionBody} | ${a.studentAnswer}");
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
          } else {
            // esse else significa que acabou os steps, agora é enviar essa bomba pro banco de dados e pro gpt
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
                InputField(
                  controller: examName,
                  labelText: "Nome da Avaliação",
                  obscureText: false,
                  validator: null,
                  onChanged: null,
                ),
                const SizedBox(height: 20),
                InputField(
                  controller: examDate,
                  labelText: "Data da Avaliação",
                  obscureText: false,
                  validator: null,
                  onChanged: null,
                ),
                const SizedBox(height: 20),
                InputField(
                  controller: examCourse,
                  labelText: "Curso",
                  obscureText: false,
                  validator: null,
                  onChanged: null,
                ),
                const SizedBox(height: 20),
                InputField(
                  controller: examSubject,
                  labelText: "Assunto",
                  obscureText: false,
                  validator: null,
                  onChanged: null,
                ),
              ],
            ),
          ),
          Step(
            isActive: _currentStep == 1,
            title: const Text("Questions and Answers"),
            content: Column(
              children: [
                for (Question q
                    in widget.csvRecord!.questionAggregator.questions)
                  QuestionDataWidgetCompact(
                      question: q,
                      aa: widget.csvRecord!.answerAggregatorList
                          .firstWhere((aa) => aa.uid == q.uid)),
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
  const QuestionDataWidgetCompact(
      {super.key, required this.question, required this.aa});

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
