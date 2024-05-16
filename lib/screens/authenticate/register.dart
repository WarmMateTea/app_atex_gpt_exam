import 'package:app_atex_gpt_exam/services/auth.dart';
import 'package:app_atex_gpt_exam/shared/constants.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key, required this.toggleView});

  final Function toggleView;  // quando essa função é ativada, como ela vem lá do authenticate, cuja render depende do estado do que toggleView() manipula, a bool do authenticate muda e ela exibe a tela de login ao invés dessa :D

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false; // TODO: implement loading :)

  //txtfield state
  String email = '';
  String password = '';
  String name = '';
  String error = '';
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        title: const Text('Cadastre-se no GPT Exam (nome sujeito a mudanças)'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.person),
            label: const Text('Login'),
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
                decoration: textInputDecoration.copyWith(labelText: 'Nome'),
                validator: ((value) => value!.isEmpty ? 'Insira um nome' : null),
                onChanged: (val) {
                  setState(() => name = val);
                }
              ),
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
                validator: ((value) => value!.length < 6 ? 'Insira uma senha com pelo menos 6 caracteres' : null),
                obscureText: true,
                onChanged: (val) {
                  setState(() => password = val);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white
                ),
                child: const Text(
                  'Cadastrar',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      loading = true;
                      error = '';
                    });

                    dynamic result = await _auth.registerWithEmailAndPassword(email, password, name);

                    if (result == null) {
                      setState(() {
                        loading = false;
                        error = "O email já está sendo usado. Por favor, insira outro email.";
                      });
                    }
                  } // o 'else' está no Main, que está escutando por mudanças de autenticação
                },
              ),
              const SizedBox(height: 12),
                Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 14)
                )
            ],
          ),
        ),
      ),
    );
  }
}