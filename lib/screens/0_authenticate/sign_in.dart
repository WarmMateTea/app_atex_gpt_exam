import 'package:app_atex_gpt_exam/widgets/input_field.dart';
import 'package:app_atex_gpt_exam/services/auth.dart';
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

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //txtfield state
  String email = '';
  String password = '';
  String error = '';

  void _sendForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
        error = '';
      });

      // n sei pq ele não aceita os controllers.text como parametro, mas
      // fodase ta funcionando
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
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo ficticia =)
                Icon(
                  Icons.run_circle_outlined,
                  size: 120,
                ),
                const Text(
                  "GPTExam",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 20),
                InputField(
                  controller: emailController,
                  labelText: "E-mail",
                  obscureText: false,
                  validator: (value) =>
                      value != null && value.isEmpty ? 'Insira um email' : null,
                  onChanged: (val) {
                    setState(() => email = emailController.text);
                  },
                ),
                const SizedBox(height: 20),
                InputField(
                  controller: passwordController,
                  labelText: "Senha",
                  obscureText: true,
                  validator: (value) => value!.length < 6
                      ? "Insira uma senha com pelo menos 6 caracteres"
                      : null,
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
                    onPressed: () {
                      _sendForm();
                    },
                    child: const Text(
                      "Entrar",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Não tem uma conta?"
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
                          "Cadastre-se"
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
