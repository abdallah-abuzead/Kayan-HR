import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kayan_hr/components/current_user_data.dart';
import 'package:kayan_hr/components/spinner.dart';
import 'package:kayan_hr/components/validation_error.dart';
import 'package:kayan_hr/models/employee_model.dart';
import 'package:kayan_hr/screens/employee_homepage.dart';
import 'package:kayan_hr/screens/homepage.dart';
import 'package:kayan_hr/screens/sign_up.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  static const String id = 'login';

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var email, password;
  bool _showEmailError = false;
  bool _showPasswordError = false;

  void login() async {
    var formData = _formKey.currentState;
    formData!.save();
    showSpinner(context);
    setState(() {
      _showEmailError = false;
      _showPasswordError = false;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.credential == null) {
        final employee = await EmployeeModel.getEmployeeByEmail(email);
        Provider.of<CurrentUserData>(context, listen: false).setRule(employee['rule_id']);
        Navigator.of(context).pushNamedAndRemoveUntil(
          employee['rule_id'] >= 3 ? HomePage.id : EmployeeHomePage.id,
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      if (e.code == 'user-not-found') {
        //No user found for that email.
        setState(() {
          _showEmailError = true;
        });
      } else if (e.code == 'wrong-password') {
        //Wrong password provided for that user.
        setState(() {
          _showPasswordError = true;
        });
      } else {
        setState(() {
          _showEmailError = true;
          _showPasswordError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr('login_title')),
      ),
      body: ListView(
        children: [
          Hero(
            tag: 'logo',
            child: Container(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: Center(
                child: Image.asset(
                  'images/logo.png',
                  scale: 3,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    onSaved: (value) {
                      email = value;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: tr('email_hint_text'),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                  ValidationError(
                    errorMessage: tr('error_email_not_found'),
                    visible: _showEmailError,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    onSaved: (value) {
                      password = value;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      hintText: tr('password_hint_text'),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                  ValidationError(
                    errorMessage: tr('error_password_incorrect'),
                    visible: _showPasswordError,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15, bottom: 30, left: 5),
                    child: Row(
                      children: [
                        Text(tr('if_you_do_not_have_account')),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pushReplacementNamed(SignUp.id);
                          },
                          child: Text(
                            tr('sign_up_title'),
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(tr('here')),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    child: Text(tr('login_title'), style: TextStyle(fontSize: 20)),
                    onPressed: () {
                      login();
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
