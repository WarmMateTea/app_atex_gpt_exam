import 'package:app_atex_gpt_exam/mixins/logout_confirmation_generic.dart';
import 'package:app_atex_gpt_exam/screens/3_explore_questions/explorer.dart';
import 'package:app_atex_gpt_exam/services/auth.dart';
import 'package:flutter/material.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key, this.user});
  final user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24), 
      child: Column(
        children: [

          // ^ Botão de Logout
          ElevatedButton.icon(
            label: const Text("Logout"),
            onPressed: () async {
              bool? shouldSignOut = await LogoutConfirmationGeneric.showConfirmationDialog(context);
              if (shouldSignOut == true) {
                AuthService().signOut();
              }
            },
            icon: const Icon(
              Icons.exit_to_app,
              size: 24,
            ),
          ),

        ],
      ),
    );
  }
}