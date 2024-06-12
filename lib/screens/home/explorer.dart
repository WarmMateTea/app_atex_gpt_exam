import 'package:app_atex_gpt_exam/models/answer.dart';
import 'package:app_atex_gpt_exam/models/answer_aggregator.dart';
import 'package:app_atex_gpt_exam/models/appUser.dart';
import 'package:app_atex_gpt_exam/models/question.dart';
import 'package:app_atex_gpt_exam/models/question_aggregator.dart';
import 'package:app_atex_gpt_exam/services/database.dart';
import 'package:app_atex_gpt_exam/shared/ai_sync_request.dart';
import 'package:flutter/material.dart';

class ExplorerBase extends StatelessWidget {
  const ExplorerBase({super.key, required this.userCompleto});
  final AppUser userCompleto;

  @override
  Widget build(BuildContext context) {
    print("[ExplorerBase, build] " + userCompleto.toString());
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
          title: Text(
            'Provas',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
          backgroundColor: Colors.blue[700],
          centerTitle: true,
          floating: true,
          snap: true,
          forceElevated: innerBoxIsScrolled,
        ),
        ];
      },
      body: ListView.builder(
        itemCount: userCompleto.exams.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(userCompleto.exams[index].name),
              onTap: () async {
                QuestionAggregator? qa = await DatabaseService().fetchQuestionAggregator(userCompleto.exams[index].questionAggregatorUID!);
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExplorerQuestions(user: userCompleto, questions: qa!.questions),
                  ),
                );
              },
            ),
          );
        },
      )
    );
  }
}

class ExplorerQuestions extends StatelessWidget {
  const ExplorerQuestions({super.key, required this.user, required this.questions});

  final AppUser user;
  final List<Question> questions;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
          title: Text(
            'Questões',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
          backgroundColor: Colors.blue[700],
          centerTitle: true,
          floating: true,
          snap: true,
          forceElevated: innerBoxIsScrolled,
        ),
        ];
      },
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(questions[index].questionBody!),
              onTap: () async {
                AnswerAggregator? aa = await DatabaseService().fetchAnswerAggregator(questions[index].answerAggregatorUID!);
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => ExplorerAnswers(user: user, question: questions[index], answers: aa!.answers),
                  )
                );
              },
            ),
          );
        },
      )
    );
  }
}

class ExplorerAnswers extends StatelessWidget {
  const ExplorerAnswers({super.key, required this.user, required this.question,required this.answers});

  final AppUser user;
  final Question question;
  final List<Answer> answers;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
          title: Text(
            'Respostas',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
          backgroundColor: Colors.blue[700],
          centerTitle: true,
          floating: true,
          snap: true,
          forceElevated: innerBoxIsScrolled,
        ),
        ];
      },
      body: ListView.builder(
        itemCount: answers.length,
        itemBuilder: (context, index) {
          return Card(
            child: AnswerCard(
              answer: answers[index],
              question: question,
            ),
          );
        },
      ),
    );
  }
}

class AnswerCard extends StatefulWidget {
  AnswerCard({super.key, required this.answer, required this.question});

  Answer answer;
  final Question question;

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.answer.studentUID,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height:4),
            Text(
              "Avaliação: ${widget.answer.rating}",
              style: const TextStyle(fontSize: 16),
            ),
            if (isExpanded) ...[
              const SizedBox(height:8),
              Text(
                "Resposta do estudante: ${widget.answer.studentAnswer}",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height:8),
              Text(
                "Correção da IA: ${widget.answer.correctionGPT}",
                style: TextStyle(fontSize: 12, color: Colors.grey[900]),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: "Regenerar correção",
                  icon: const Icon(Icons.refresh),
                  onPressed: () async {
                    // refaz o request e atualiza a answer exibida; talvez congele rapidinho
                    Answer newAnswer = await SyncGPTRequest.singleRequest(widget.question, widget.answer);
                    setState(() {
                      widget.answer = newAnswer;
                    });
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}