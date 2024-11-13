import 'package:app_atex_gpt_exam/models/appUser.dart';
import 'package:app_atex_gpt_exam/screens/1_home/gpt_interface.dart';
import 'package:app_atex_gpt_exam/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CreateQuestionPage extends StatefulWidget {
  CreateQuestionPage({super.key, required this.user});
  AppUser user;

  @override
  State<CreateQuestionPage> createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage> {
  final TextEditingController areaAndCourse = TextEditingController();
  final TextEditingController questionTheme = TextEditingController();
  final TextEditingController output = TextEditingController();

  bool considerBloom = true;
  bool isDiscursive = true;

  QuestionRequest? questionObj;

  void _createQuestionRequestObj() {
    questionObj = QuestionRequest(
      areaAndCourse: areaAndCourse.text, 
      data: questionTheme.text, 
      considerBloom: considerBloom, 
      isDiscursive: isDiscursive
      );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Área e Curso da questão
          TextField(
            controller: areaAndCourse,
            maxLines: 1,
            decoration: Defaults.getDefaultTextInputDeco(
              controller: areaAndCourse,
              clearButton: true,
              labelText: "Área e Curso",
              hintText: "Ex: Programação Paralela, Ciência da Computação")
          ),
          const SizedBox(width: 0, height: 12),
      
          // Tema da questão
          TextField(
            controller: questionTheme,
            maxLines: null,
            decoration: Defaults.getDefaultTextInputDeco(
              controller: questionTheme,
              clearButton: true,
              labelText: "Tema da Questão",
              hintText: "Ex: O que é a Lei de Amdahl?")
          ),
          const SizedBox(width: 0, height: 12),
      
          // Checkbox: Considerar a taxonomia de bloom
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(value: considerBloom, onChanged: (val) {
                setState(() {
                  considerBloom = val!;
                });
              }),
              const SizedBox(width: 4,),
              const Text("Considerar a taxonomia de bloom"),
            ],
          ),
          const SizedBox(width: 0, height: 12),
      
          // Checkbox: Questão discursiva
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(value: isDiscursive, onChanged: (val) {
                setState(() {
                  isDiscursive = val!;
                });
              }),
              const SizedBox(width: 4,),
              const Text("Questão discursiva"),
            ],
          ),
          const SizedBox(width: 0, height: 12),
      
          if (questionObj == null)
            FilledButton.icon(
              onPressed: () => _createQuestionRequestObj(), 
              label: const Text("Gerar Questão"),
              icon: const Icon(Icons.play_arrow_outlined))
          else
            QuestaoGerada(
              output: output, 
              obj: questionObj!
            )
        ],
      ),
    );
  }
}

class QuestaoGerada extends StatelessWidget {
  QuestaoGerada({super.key, required this.output, required this.obj});
  final TextEditingController output;
  final QuestionRequest obj;
  late Future<String> future = _init();

  Future<String> _init() async {
    return GptInterfaceCreateQuestion.generateQuestion(obj);
  }

  List<TextSpan> _buildTextSpans(String text) {
    List<TextSpan> spans = [];
     RegExp exp = RegExp(r'\\(.)|(\*\*(.*?)\*\*)|([^*]+)');
    Iterable<RegExpMatch> matches = exp.allMatches(text);

    for (var match in matches) {
      if (match.group(2) != null) {
        // This is the bold text (inside **)
        spans.add(TextSpan(
          text: match.group(3), // Updated to get the bold text correctly
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(1) != null) {
        // This is an escaped character
        spans.add(TextSpan(
          text: match.group(1), // Group for the escaped character
        ));
      } else if (match.group(4) != null) {
        // This is the regular text
        spans.add(TextSpan(
          text: match.group(4), // Group for the regular text
        ));
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder(future: future, builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
              String answer = snapshot.data ?? "erro ao gerar questão 😢";

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min ,
                  children: [
                    SelectableText.rich(
                      TextSpan(
                        children: _buildTextSpans(answer),
                      )
                    ),
                    const SizedBox(width: 0, height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: answer));
                        //copia o conteúdo pro clipboard :D
                      }, 
                      icon: const Icon(
                        Icons.copy
                      ),
                      label: const Text(
                        "Copiar Resposta",
                      ))
                  ],
                ),
              );
              
            } else if (snapshot.hasError) {
              return Container(
                color: Colors.red,
                child: Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline),
                    const Text("Erro ao gerar questão 😢"),
                    Text('Error: ${snapshot.error}'),
                  ],
                )),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          })
    );
  }
}

/// Plug-in que renderize LaTeX