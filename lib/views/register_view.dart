import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(hintText: 'E-mail'),
          enableSuggestions: false,
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
          controller: _email,
        ),
        TextField(
          decoration: const InputDecoration(hintText: 'Password'),
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          controller: _password,
        ),
        TextButton(
          onPressed: () async {
            final email = _email.text;
            final password = _password.text;

            try {
              final userCredential =
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: email,
                password: password,
              );
              print(userCredential);
            } on FirebaseAuthException catch (e) {
              if (e.code == 'weak-password') {
                print('Weak Passworld');
              } else if (e.code == 'email-already-in-use') {
                print('This e-mail is already in use');
              } else if (e.code == 'invalid-email') {
                print('Invalid E-mail');
              }
            }
          },
          child: const Text('Register'),
        ),
      ],
    );
  }
}
