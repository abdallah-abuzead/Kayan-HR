import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kayan_hr/components/show_snack_bar.dart';
import 'package:kayan_hr/components/spinner.dart';
import 'package:kayan_hr/components/validation_error.dart';
import 'package:kayan_hr/models/employee_model.dart';
import 'package:kayan_hr/models/user_model.dart';
import 'package:kayan_hr/screens/homepage.dart';

class CreateNewAdmin extends StatefulWidget {
  const CreateNewAdmin({Key? key}) : super(key: key);
  static const String id = 'create_new_admin';

  @override
  _CreateNewAdminState createState() => _CreateNewAdminState();
}

class _CreateNewAdminState extends State<CreateNewAdmin> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var name, email, password;
  bool _showEmailError = false;

  void createAdmin() async {
    setState(() {
      _showEmailError = false;
    });

    var formData = _formKey.currentState;
    if (formData!.validate()) {
      formData.save();
      showSpinner(context);
      if (await EmployeeModel.isEmailExists(email)) {
        // check if it isn't an employee added in the system
        setState(() {
          _showEmailError = true;
          Navigator.of(context).pop();
        });
      } else {
        // add in employee collection
        await EmployeeModel.addEmployee({
          'name': name,
          'email': email,
          'image_url': '',
          'rule_id': 3,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
        String currentUserEmail = UserModel.currentUserEmail;
        try {
          // add in firebase users
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          if (userCredential.credential == null) {
            // add in user collection
            var user = {
              'name': name,
              'email': email,
              'password': password,
              'phone': '',
              'created_at': DateTime.now().millisecondsSinceEpoch,
              'updated_at': DateTime.now().millisecondsSinceEpoch,
            };
            await UserModel.addUser(user);
            // login again with the current user
            final currentUser = await UserModel.getUserByEmail(currentUserEmail);
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: currentUserEmail,
              password: currentUser['password'],
            );

            successSnackBar(context, tr('new_admin_indicator'));
            Navigator.of(context).pushNamedAndRemoveUntil(HomePage.id, (route) => false);
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
        title: Text(tr('create_new_admin_title')),
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
                    errorMessage: tr('validate_email_exists'),
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
                  ElevatedButton(
                    child: Text(tr('create_button'), style: TextStyle(fontSize: 20)),
                    onPressed: () {
                      createAdmin();
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
