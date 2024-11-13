import 'package:flutter/material.dart';

mixin LogoutConfirmationGeneric {
  static Future<bool?> showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Deseja sair de sua conta?'),
          content: const Text('Você precisará fazer Login novamente.'),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Não'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );
  }
}

