import 'package:flutter/material.dart';
import 'package:group_checklist/pages/dashboard.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auth_buttons/auth_buttons.dart';

import 'db/db.dart';
import './api/googleauthapi.dart';

// it has to be stateful, or because of context

class Login extends StatelessWidget {
  Login({Key? key}) : super(key: key);
  final Box box = Hive.box("accounts10");

  @override
  final bool signOption = true;
  Color col = Colors.grey;

  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPWController = TextEditingController();

  Future signInWithGoogle(BuildContext context) async {
    final user = await GoogleSignInApi.login();
    if (user != null) {
      if (box.get(user.email) == null) {
        Account acc = Account(
            email: user.email,
            name: user.displayName!,
            id: user.id,
            events: []);
        box.put(user.email, acc);
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => Dashboard(user: box.get(user.email))));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Sign in failed")));
    }
  }

  void signInWithEmail(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: ((context) => emailLogin(context))));
  }

  TextField formInput(String type) {
    switch (type) {
      case 'email':
        return TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ));
      case 'pw':
        return TextField(
            controller: pwController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.security),
            ));
      case 'confirmPW':
        return TextField(
            controller: confirmPWController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm password',
              prefixIcon: Icon(Icons.security),
            ));
      case 'name':
        return TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person),
            ));
    }
    return const TextField();
  }

  Widget emailLogin(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: const EdgeInsets.all(32.0),
            child: ListView(
              children: <Widget>[
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context, true)),
                    Center(
                        child: Text("Sign in",
                            style: GoogleFonts.montserrat(fontSize: 16))),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(32.0)),
                formInput("email"),
                formInput("pw"),
                OutlinedButton(
                    child: const Text("Sign in"),
                    onPressed: () {
                      if (box.get(emailController.text) != null) {
                        if (box.get(emailController.text).password ==
                            pwController.text) {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => Dashboard(
                                      user: box
                                          .get(emailController.text))),
                              ((route) => false));
                        }
                      }
                    }),
                const Padding(padding: EdgeInsets.all(32.0)),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => emailSignUp(context))));
                    },
                    child: const Text("Sign up"))
              ],
            )));
  }

  Widget emailSignUp(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: const EdgeInsets.all(32.0),
            child: ListView(
              children: <Widget>[
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context, true)),
                    Center(
                        child: Text("Sign up",
                            style: GoogleFonts.montserrat(fontSize: 16))),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(32.0)),
                formInput("name"),
                formInput("email"),
                formInput("pw"),
                formInput("confirmPW"),
                OutlinedButton(
                    child: const Text("Sign up"),
                    onPressed: () {
                      if (pwController.text == confirmPWController.text) {
                        box.put(
                            emailController.text,
                            Account(
                                email: emailController.text,
                                name: nameController.text,
                                password: pwController.text,
                                events: []));
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => emailLogin(context))));
                      } else {}
                    }),
                const Padding(padding: EdgeInsets.all(32.0)),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => emailLogin(context))));
                    },
                    child: const Text("Sign in"))
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(32.0),
        children: <Widget>[
          Center(
            child: Text("Welcome to Freebie!",
                style: GoogleFonts.montserrat(fontSize: 32)),
          ),
          const Padding(padding: EdgeInsets.all(12.0)),
          Image.asset("assets/donating.png"),
          ElevatedButton(
              onPressed: () => signInWithEmail(context),
              child: Row(
                children: const [
                  Padding(padding: EdgeInsets.only(left: 64.0)),
                  Icon(Icons.email),
                  Padding(padding: EdgeInsets.only(left: 16.0)),
                  Text('Sign in with email'),
                ],
              ),
              style: ElevatedButton.styleFrom(
                  textStyle: GoogleFonts.montserrat(fontSize: 16),
                  shadowColor: Colors.grey,
                  elevation: 2.0,
                  minimumSize: const Size(280, 50))),
          const Padding(padding: EdgeInsets.all(16.0)),
          GoogleAuthButton(
              onPressed: () => signInWithGoogle(context),
              darkMode: false,
              style: AuthButtonStyle(
                  textStyle: GoogleFonts.montserrat(
                      fontSize: 16, color: Colors.black)))
        ],
      ),
      backgroundColor: const Color(0xffb099e1),
    );
  }
}
