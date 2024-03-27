//a
//b
//c

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tp_api/views/main_screen.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:tp_api/main.dart';

class LoginScreen extends StatelessWidget {

  Future<String?> _authUser(LoginData data) async {
    print('Attempting authentication for: ${data.name}'); // Ajout pour le débogage

    final response = await supabase
        .from('account')
        .select('name, password')
        .eq('name', data.name);

    for (var row in response) {
      String? name = row['name'];
      String? password = row['password'];
      if (name == data.name && password == data.password) {
        // Authentication successful
        print('Authentication successful for: ${data.name}'); // Ajout pour le débogage
        return null;
      }
    }
    print('Authentication failed for: ${data.name}'); // Ajout pour le débogage
    return "Invalid username or password";
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Mon App',
      logo: 'assets/Logo.png', // Chemin vers votre image
      theme: LoginTheme(
        primaryColor: Colors.blue, // Couleur principale de l'écran de connexion
        accentColor: Colors.white, // Couleur d'accentuation
        errorColor: Colors.red, // Couleur des erreurs
        titleStyle: TextStyle(
          color: Colors.black, // Couleur du titre
        ),
      ),
      onLogin: _authUser,
      onSignup: _createUser,
      onRecoverPassword: _recoverPassword,
      messages: LoginMessages(
        userHint: "Nom d'utilisateur",
        passwordHint: "Mot de passe",
        confirmPasswordHint: "Confirmer le mot de passe",
        forgotPasswordButton: "Mot de passe oublié ?",
        loginButton: "CONNEXION",
        signupButton: "INSCRIPTION",
        recoverPasswordIntro: "Récupérez votre mot de passe",
        recoverPasswordDescription: "Nous vous enverrons un email pour réinitialiser votre mot de passe",
        goBackButton: "RETOUR",
        confirmPasswordError: "Les mots de passe ne correspondent pas!",
      ),
      userValidator: (value) {
        if (value!.isEmpty) {
          return "Le nom d'utilisateur ne peut pas être vide";
        }
        if (value.contains(' ')) {
          return "Le nom d'utilisateur ne peut pas contenir d'espaces";
        }
        return null;
      },
      passwordValidator: (text) {
        if (text!.isEmpty) {
          return "Le mot de passe ne peut pas être vide";
        }
        if (text.contains(' ')) {
          return "Le mot de passe ne peut pas contenir d'espaces";
        }
        return null;
      },
      onSubmitAnimationCompleted: () {
        print('Login successful'); // Ajout pour le débogage
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MainScreen(),
        ));
      },
    );
  }

  Future<String?> _createUser(SignupData data) async {
    try {
      print('Creating user: ${data.name}'); // Ajout pour le débogage

      // Assuming you have a 'account' table in your Supabase database
      final response = await supabase.from('account').insert([
        {
          'name': data.name,
          'password': data.password,
        }
      ]);

      if (response.error != null) {
        // If there's an error while inserting
        print('User creation failed: ${response.error!.message}'); // Ajout pour le débogage
        return response.error!.message;
      } else {
        // User creation successful
        print('User created successfully: ${data.name}'); // Ajout pour le débogage
        return null;
      }
    } catch (error) {
      // If there's any unexpected error
      print('Error creating user: $error'); // Ajout pour le débogage
      return "An error occurred while creating the user: $error";
    }
  }

  Future<String?> _recoverPassword(String name) {
    // Logique pour la récupération du mot de passe
    print('Password recovery request for: $name'); // Ajout pour le débogage
    return Future.value('');
  }
}

