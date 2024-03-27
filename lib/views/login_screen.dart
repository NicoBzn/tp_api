
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tp_api/views/main_screen.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:tp_api/main.dart';

class LoginScreen extends StatelessWidget { //création de la class

  Future<String?> _authUser(LoginData data) async {
    print('Attempting authentication for: ${data.name}');//debug pour vérifier que

    final response = await supabase //requete supabase
        .from('account')
        .select('name, password')
        .eq('name', data.name);

    for (var row in response) { //verification du nom d'utilisateur et du mot de passe
      String? name = row['name'];
      String? password = row['password'];
      if (name == data.name && password == data.password) {
        // Authentication successful
        print('Authentication successful for: ${data.name}');//debug
        return null;
      }
    }
    print('Authentication failed for: ${data.name}');//debug
    return "Invalid username or password";
  }

  @override
  Widget build(BuildContext context) {//fenetre graphique
    return FlutterLogin(
      title: 'Search Appli',
      logo: 'assets/Logo.png',
      theme: LoginTheme(
        primaryColor: Colors.blue,
        accentColor: Colors.white,
        errorColor: Colors.red,
        titleStyle: TextStyle(
          color: Colors.black,
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
        print('Login successful'); //debug
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MainScreen(),
        ));
      },
    );
  }

  Future<String?> _createUser(SignupData data) async {
    try {
      print('Creating user: ${data.name}'); //debug

      final response = await supabase.from('account').insert([
        {
          'name': data.name,
          'password': data.password,
        }
      ]);

      if (response.error != null) {
        print('User creation failed: ${response.error!.message}'); //debug
        return response.error!.message;
      } else {
        print('User created successfully: ${data.name}'); //debug
        return null;
      }
    } catch (error) {
      print('Error creating user: $error'); //debug
      return "An error occurred while creating the user: $error";
    }
  }

  Future<String?> _recoverPassword(String name) {
    print('Password recovery request for: $name'); //debug
    return Future.value('');
  }
}

