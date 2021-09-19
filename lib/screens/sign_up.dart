import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kayan_hr/components/current_user_data.dart';
import 'package:kayan_hr/components/spinner.dart';
import 'package:kayan_hr/components/validation_error.dart';
import 'package:kayan_hr/models/employee_model.dart';
import 'package:kayan_hr/models/user_model.dart';
import 'package:kayan_hr/screens/employee_homepage.dart';
import 'package:kayan_hr/screens/login.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);
  static const String id = 'sign_up';

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var name, email, password, phone;
  bool _showEmailError = false;
  String emailErrorMessage = '';

  void signUp() async {
    setState(() {
      _showEmailError = false;
    });

    var formData = _formKey.currentState;
    if (formData!.validate()) {
      formData.save();
      showSpinner(context);
      if (await UserModel.isEmailExist(email)) {
        // check if admin or an employee has a user account
        setState(() {
          _showEmailError = true;
          emailErrorMessage = tr('validate_email_exists');
          Navigator.of(context).pop();
        });
      } else if (!await EmployeeModel.isEmailExists(email)) {
        // check if it isn't an employee added in the system
        setState(() {
          _showEmailError = true;
          emailErrorMessage = tr('error_email_unauthorized');
          Navigator.of(context).pop();
        });
      } else {
        try {
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          if (userCredential.credential == null) {
            var user = {
              'name': name,
              'email': email,
              'password': password,
              'phone': phone,
              'created_at': DateTime.now().millisecondsSinceEpoch,
              'updated_at': DateTime.now().millisecondsSinceEpoch,
            };
            await UserModel.addUser(user);
            final employee = await EmployeeModel.getEmployeeByEmail(email);
            Provider.of<CurrentUserData>(context, listen: false).setRule(employee['rule_id']);
            Navigator.of(context).pushNamedAndRemoveUntil(EmployeeHomePage.id, (route) => false);
          }
        } on FirebaseAuthException catch (e) {
          print(e);
        } catch (e) {
          print(e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr('sign_up_title')),
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
                      name = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) return tr('validate_name_required');
                      if (value.length < 2) return tr('validate_name_min_length_2');
                      if (value.length > 100) return tr('validate_name_max_length_100');
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      suffixIcon: Icon(Icons.star_rate_rounded, color: Colors.red.shade500, size: 14),
                      hintText: tr('name_hint_text'),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    onSaved: (value) {
                      email = value;
                    },
                    validator: (value) {
                      bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value!);
                      if (value.isEmpty) return tr('validate_email_required');
                      if (!emailValid) return tr('validate_email_format');
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      suffixIcon: Icon(Icons.star_rate_rounded, color: Colors.red.shade500, size: 14),
                      hintText: tr('email_hint_text'),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                  ValidationError(
                    errorMessage: emailErrorMessage,
                    visible: _showEmailError,
                  ),
                  SizedBox(height: 5),
                  TextFormField(
                    onSaved: (value) {
                      password = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) return tr('validate_password_required');
                      if (value.length < 6) return tr('validate_password_min_length_6');
                      if (value.length > 100) return tr('validate_password_max_length_100');
                      return null;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.star_rate_rounded, color: Colors.red.shade500, size: 14),
                      hintText: tr('password_hint_text'),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    onSaved: (value) {
                      phone = value;
                    },
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      hintText: tr('phone_hint_text'),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15, bottom: 30, left: 5),
                    child: Row(
                      children: [
                        Text(tr('if_you_already_have_account')),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pushReplacementNamed(Login.id);
                          },
                          child: Text(
                            tr('login_title'),
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
                    child: Text(tr('sign_up_title'), style: TextStyle(fontSize: 20)),
                    onPressed: () {
                      signUp();
                    },
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
