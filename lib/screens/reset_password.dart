import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kayan_hr/components/show_snack_bar.dart';
import 'package:kayan_hr/components/spinner.dart';
import 'package:kayan_hr/components/validation_error.dart';
import 'package:kayan_hr/models/user_model.dart';
import 'package:kayan_hr/screens/homepage.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);
  static const String id = 'reset_password';

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var currentPassword, newPassword, repeatPassword;
  bool _showCurrentPasswordError = false;

  void save() async {
    setState(() {
      _showCurrentPasswordError = false;
    });
    var formData = _formKey.currentState;
    if (formData!.validate()) {
      formData.save();
      showSpinner(context);
      final user = await UserModel.getUserByEmail(UserModel.currentUserEmail);
      if (currentPassword != user['password']) {
        setState(() {
          Navigator.of(context).pop();
          _showCurrentPasswordError = true;
        });
      } else {
        await UserModel.resetPassword(currentPassword, newPassword);
        await UserModel.updateUser(user.id, {'password': newPassword});

        successSnackBar(context, tr('reset_password_indicator'));

        Navigator.of(context).pushNamedAndRemoveUntil(HomePage.id, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr('reset_password_title')),
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
                      currentPassword = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) return tr('validate_current_password_required');
                      if (value.length < 6) return tr('validate_current_password_wrong');
                      return null;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_open),
                      hintText: tr('current_password_hint_text'),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                  ValidationError(
                    errorMessage: tr('validate_current_password_wrong'),
                    visible: _showCurrentPasswordError,
                  ),
                  SizedBox(height: 5),
                  TextFormField(
                    onSaved: (value) {
                      newPassword = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) return tr('validate_new_password_required');
                      if (value.length < 6) return tr('validate_password_min_length_6');
                      if (value.length > 100) return tr('validate_password_max_length_100');
                      return null;
                    },
                    onChanged: (value) {
                      newPassword = value;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      hintText: tr('new_password_hint_text'),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    onSaved: (value) {
                      repeatPassword = value;
                    },
                    validator: (value) {
                      if (value != newPassword) return tr('validate_repeated_password');
                      return null;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      hintText: tr('repeat_password_hint_text'),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    child: Text(tr('save_button'), style: TextStyle(fontSize: 20)),
                    onPressed: () {
                      save();
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
