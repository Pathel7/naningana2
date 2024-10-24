import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:naningana/components/afficherMessageInfo.dart';
import 'package:naningana/components/myBytton.dart';
import 'package:naningana/components/myTextField.dart';
import 'package:naningana/helperFunctions.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isSecret = true;

  // Fonction pour vérifier si l'utilisateur a déjà répondu au questionnaire
  Future<bool> hasAlreadyAnswered(String userId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('fiche_medical')
        .doc(userId)
        .get();

    return snapshot.exists; // Si le document existe, il a déjà répondu
  }

  void login() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.orangeAccent,
        ),
      ),
    );

    try {
      // Authentification avec Firebase
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Récupération de l'utilisateur
      User? user = userCredential.user;

      // Si l'utilisateur est bien connecté
      if (user != null) {
        // Vérification s'il a déjà répondu au questionnaire
        bool alreadyAnswered = await hasAlreadyAnswered(user.uid);

        // Si le widget est encore monté, on ferme le loader
        if (mounted) {
          Navigator.pop(context); // Fermer le CircularProgressIndicator
        }

        // Si le widget est encore monté, on redirige en fonction de la réponse
        if (mounted) {
          if (alreadyAnswered) {
            afficherMessageInfo(context, "Vous avez déjà répondu au questionnaire.", Colors.red, Colors.white);
            Navigator.pushNamed(context, "/already_answered_page");
          } else {
            afficherMessageInfo(context, "Connecté en tant que : ${emailController.text}", Colors.green, Colors.white);
            Navigator.pushNamed(context, "/home_page");
          }
        }
      }
    } catch (e) {
      // Fermer la boîte de dialogue si une erreur survient et si le widget est encore monté
      if (mounted) {
        Navigator.pop(context);
      }

      // Gérer les erreurs d'authentification Firebase
      if (e is FirebaseAuthException) {
        handleAuthError(e, context); // Fonction pour afficher un message d'erreur spécifique
      } else {
        afficherMessageInfo(context, "Une erreur inattendue s'est produite.", Colors.red, Colors.white);
      }
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Center(
          child: Card(
            elevation: 0,
            color: Colors.grey.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 35),
                      const Text(
                        "Connectez-vous à votre compte",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "pour commencer",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 60),
                      // email
                      MyTextField(
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Colors.black,
                        ),
                        hintText: "email",
                        obscureText: false,
                        controller: emailController,
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        obscureText: _isSecret,
                        suffixIcon: InkWell(
                          onTap: () => setState(() {
                            _isSecret = !_isSecret;
                          }),
                          child: Icon(_isSecret ? Icons.visibility : Icons.visibility_off),
                        ),
                        hintText: "mot de passe",
                        controller: passwordController,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'mot de passe oublié ? ',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      MyButton(onTap: login, text: "Se connecter"),
                      const SizedBox(height: 25),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Vous n'avez pas de compte ?",
                            style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                          ),
                          const SizedBox(height: 15.0),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: const Text(
                              "  Cliquez ici",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
