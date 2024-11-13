import 'package:app_atex_gpt_exam/shared/which_ai.dart';
import 'package:flutter/material.dart';

class ChangeAiFab extends StatefulWidget {
  const ChangeAiFab({
    super.key,
  });

  @override
  State<ChangeAiFab> createState() => _ChangeAiFabState();
}

class _ChangeAiFabState extends State<ChangeAiFab> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        setState(() {WhichAi.instance.toggleAiType();});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usando ${WhichAi.instance.getAiType()} agora!')));
      },
      backgroundColor: WhichAi.instance.getAiBgColor(),
      child: WhichAi.instance.getAiIcon(),
    );
  }
}

