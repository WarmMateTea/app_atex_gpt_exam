import 'package:app_atex_gpt_exam/screens/widgets/input_field.dart';
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
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   backgroundColor: Colors.blue[900],
      //   elevation: 0,
      //   title: const Text('Entrar no GPT Exam (nome sujeito a mudanças)'),
      //   actions: [
      //     TextButton.icon(
      //       icon: const Icon(Icons.person),
      //       label: const Text('Cadastrar'),
      //       onPressed: () => widget.toggleView(),
      //     ),
      //   ],
      // ),
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
                  color: Colors.blue.shade600,
                  size: 120,
                ),
                const Text(
                  "GPTExam",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 20),
                // TextFormField(
                //   decoration: textInputDecoration.copyWith(labelText: 'Email'),
                //   validator: ((value) =>
                //       value!.isEmpty ? 'Insira um email' : null),
                //   onChanged: (val) {
                //     setState(() => email = val);
                //   },
                // ),
                InputField(
                  controller: emailController,
                  labelText: "E-mail",
                  obscureText: false,
                  validator: (value) =>
                      value != null && value.isEmpty ? 'Insira um email' : null,
                ),
                const SizedBox(height: 20),
                // TextFormField(
                //   decoration: textInputDecoration.copyWith(labelText: 'Senha'),
                //   validator: ((value) => value!.length < 6
                //       ? "Insira uma senha com pelo menos 6 caracteres"
                //       : null),
                //   obscureText: true,
                //   onChanged: (val) {
                //     setState(() => password = val);
                //   },
                //   onFieldSubmitted: (value) => _sendForm(),
                // ),
                InputField(
                  controller: passwordController,
                  labelText: "Senha",
                  obscureText: true,
                  validator: (value) => value!.length < 6
                      ? "Insira uma senha com pelo menos 6 caracteres"
                      : null,
                ),
                const SizedBox(height: 20),
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.blue[900],
                //   ),
                //   child: const Text(
                //     'Entrar',
                //     style: TextStyle(
                //         color: Colors.white, fontWeight: FontWeight.bold),
                //   ),
                //   onPressed: () => _sendForm(),
                // ),
                Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    shape: const StadiumBorder(),
                    // color: AppColors.defaultAppColor,
                    // TODO: Com gradiente ou sem (?)
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
                      _sendForm();
                    },
                    child: const Text(
                      "Entrar",
                      style: TextStyle(
                          color: Colors.white,
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
                      "Não tem uma conta?",
                      style: TextStyle(color: Colors.white70),
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
                          "Cadastre-se",
                          style: TextStyle(
                            color: Colors.blue.shade600,
                          ),
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
