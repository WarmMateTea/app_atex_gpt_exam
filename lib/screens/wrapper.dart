import 'package:app_atex_gpt_exam/models/appUser.dart';
import 'package:app_atex_gpt_exam/screens/authenticate/authenticate.dart';
import 'package:app_atex_gpt_exam/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<AppUser?>(context);
    print('\ncurrent user provided:' + user.toString());
    print('^ from: Wrapper at ${DateTime.now()}');

    // dependendo da autenticação (se user == null, nenhum user logado) redirecionar para tela de autenticação ou home direto
    if (user == null) {
      return const Authenticate();
    } else {
      return Home(appUser: user);
    }
  }
}