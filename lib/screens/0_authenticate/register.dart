import 'package:app_atex_gpt_exam/services/auth.dart';
import 'package:app_atex_gpt_exam/widgets/input_field.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key, required this.toggleView});

  final Function
      toggleView; // quando essa função é ativada, como ela vem lá do authenticate, cuja render depende do estado do que toggleView() manipula, a bool do authenticate muda e ela exibe a tela de login ao invés dessa :D

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

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.black,
      // appBar: AppBar(
      //   backgroundColor: Colors.blue[900],
      //   elevation: 0,
      //   title: const Text('Cadastre-se no GPT Exam (nome sujeito a mudanças)'),
      //   actions: [
      //     TextButton.icon(
      //       icon: const Icon(Icons.person),
      //       label: const Text('Login'),
      //       onPressed: () => widget.toggleView(),
      //     ),
      //   ],
      // ),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.run_circle_outlined,
                  //color: Colors.blue.shade600,
                  size: 120,
                ),
                const Text(
                  "GPTExam",
                  style: TextStyle(
                    //color: Colors.white,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 20),
                InputField(
                  controller: nameController,
                  labelText: "Nome",
                  obscureText: false,
                  validator: (value) =>
                      value != null && value.isEmpty ? 'Insira seu nome' : null,
                  onChanged: (val) {
                    setState(() => name = nameController.text);
                  },
                ),
                const SizedBox(height: 20),
                InputField(
                  controller: emailController,
                  labelText: "E-mail",
                  obscureText: false,
                  validator: (value) => value != null && value.isEmpty
                      ? 'Insira seu e-mail'
                      : null,
                  onChanged: (val) {
                    setState(() => email = emailController.text);
                  },
                ),
                const SizedBox(height: 20),
                InputField(
                  controller: passwordController,
                  labelText: "Senha",
                  obscureText: true,
                  validator: ((value) => value!.length < 6
                      ? 'Insira uma senha com pelo menos 6 caracteres'
                      : null),
                  onChanged: (val) {
                    setState(() => password = passwordController.text);
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: const ShapeDecoration(
                    shape: StadiumBorder(),
                  ),
                  child: FilledButton(
                    style: const ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                          error = '';
                        });

                        dynamic result =  await _auth.registerWithEmailAndPassword(email, password, name);

                        if (result == null) {
                          setState(() {
                            loading = false;
                            error =
                                "O email já está sendo usado. Por favor, insira outro email.";
                          });
                        }
                      } // o 'else' está no Main, que está escutando por mudanças de autenticação
                    },
                    child: const Text(
                      "Cadastrar",
                      style: TextStyle(
                        //color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      ),  
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Já possuí uma conta?",
                      //style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.toggleView();
                      },
                      style: const ButtonStyle(
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Faça o Login",
                          style: TextStyle(
                            //color: Colors.blue.shade600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(error,
                    style: const TextStyle(color: Colors.red, fontSize: 14))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
