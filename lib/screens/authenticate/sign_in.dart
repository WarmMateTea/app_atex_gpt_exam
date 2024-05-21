import 'package:app_atex_gpt_exam/services/auth.dart';
import 'package:app_atex_gpt_exam/shared/constants.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key, required this.toggleView});

  final Function toggleView;

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false; // TODO: implement loading

  //txtfield state
  String email = '';
  String password = '';
  String error = '';

  void _sendForm () async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
        error = '';
      });

      dynamic result = await _auth.signInWithEmailAndPassword(email, password);

      if (result == null) {
        setState(() {
          loading = false;
          error = 'Email ou senha inválidos 😢';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        title: const Text('Entrar no GPT Exam (nome sujeito a mudanças)'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.person),
            label: const Text('Cadastrar'),
            onPressed: () => widget.toggleView(),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                decoration: textInputDecoration.copyWith(labelText: 'Email'),
                validator: ((value) => value!.isEmpty ? 'Insira um email' : null),
                onChanged: (val) {
                  setState(() => email = val);
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: textInputDecoration.copyWith(labelText: 'Senha'),
                validator: ((value) => value!.length < 6 ? "Insira uma senha com pelo menos 6 caracteres" : null),
                obscureText: true,
                onChanged: (val) {
                  setState(() => password = val);
                },
                onFieldSubmitted: (value) => _sendForm(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _sendForm(),
              ),
              const SizedBox(height:12),
              Text(error, style: const TextStyle(color: Colors.red, fontSize: 14),),
            ],
          ),
        ),
      ),
    );
  }
}