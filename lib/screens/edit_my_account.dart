import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kayan_hr/components/current_user_data.dart';
import 'package:kayan_hr/components/show_snack_bar.dart';
import 'package:kayan_hr/components/spinner.dart';
import 'package:kayan_hr/components/validation_error.dart';
import 'package:kayan_hr/models/employee_model.dart';
import 'package:kayan_hr/models/user_model.dart';
import 'package:kayan_hr/screens/homepage.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import '../constants.dart';

class EditMyAccount extends StatefulWidget {
  const EditMyAccount({Key? key}) : super(key: key);
  static const String id = 'edit_my_account';

  @override
  _EditMyAccountState createState() => _EditMyAccountState();
}

class _EditMyAccountState extends State<EditMyAccount> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var userId, name, oldEmail, newEmail, phone;
  bool _showEmailError = false;
  late File file;
  final ImagePicker picker = ImagePicker();
  String pickedImagePath = '';
  var imageUrl;
  var imageName;

  void save(BuildContext context) async {
    var formData = _formKey.currentState;
    if (formData!.validate()) {
      formData.save();
      showSpinner(context);
      // update employee email and firebase user email
      if (newEmail != oldEmail && await EmployeeModel.isEmailExists(newEmail)) {
        setState(() {
          _showEmailError = true;
          Navigator.of(context).pop();
        });
      } else {
        // update employee email
        final employee = await EmployeeModel.getEmployeeByEmail(oldEmail);
        if (pickedImagePath != '') {
          await EmployeeModel.deleteEmployeeImage(imageUrl);
          imageUrl = await EmployeeModel.storeEmployeeImage(imageName, file);
        }
        await EmployeeModel.updateEmployee(employee.id, {'email': newEmail, 'image_url': imageUrl});
        // update firebase user email
        await UserModel.updateUserEmailOnFirebase(oldEmail, newEmail);
        // update user data
        await UserModel.updateUser(
          userId,
          {
            'name': name,
            'email': newEmail,
            'phone': phone,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
        );

        successSnackBar(context, tr('edit_my_account_indicator'));
        Navigator.of(context).pushNamedAndRemoveUntil(HomePage.id, (route) => false);
      }
    }
  }

  void initUI() async {
    final user = await UserModel.getUserByEmail(UserModel.currentUserEmail);
    final employee = await EmployeeModel.getEmployeeByEmail(UserModel.currentUserEmail);
    setState(() {
      userId = user.id;
      name = user['name'];
      oldEmail = user['email'];
      phone = user['phone'];
      imageUrl = employee['image_url'];
    });
  }

  @override
  void initState() {
    super.initState();
    initUI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr('edit_my_account_title')),
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
          userId == null
              ? Container()
              : Container(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          initialValue: name,
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
                          initialValue: oldEmail,
                          readOnly: Provider.of<CurrentUserData>(context).rule != 3,
                          onSaved: (value) {
                            newEmail = value;
                          },
                          validator: (value) {
                            bool emailValid =
                                RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
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
                          initialValue: phone,
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
                        SizedBox(height: 10),
                        Provider.of<CurrentUserData>(context).rule < 3
                            ? Container()
                            : TextFormField(
                                onTap: () async {
                                  final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);
                                  if (pickedImage != null) {
                                    setState(() {
                                      file = File(pickedImage.path);
                                      pickedImagePath = pickedImage.path;
                                    });
                                    imageName =
                                        '${DateTime.now().millisecondsSinceEpoch}-${basename(pickedImage.path)}';
                                  }
                                },
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: pickedImagePath == '' ? '' : pickedImagePath,
                                  prefixIcon: Icon(Icons.image),
                                  suffixIcon: pickedImagePath == ''
                                      ? imageUrl == ''
                                          ? Container(
                                              margin: context.locale == Locale('ar', 'DZ')
                                                  ? EdgeInsets.only(left: 10)
                                                  : EdgeInsets.only(right: 10),
                                              child: Image.asset('images/avatar.png'),
                                              width: double.minPositive,
                                              height: double.minPositive,
                                            )
                                          : Container(
                                              margin: context.locale == Locale('ar', 'DZ')
                                                  ? EdgeInsets.only(left: 10)
                                                  : EdgeInsets.only(right: 10),
                                              child: Image.network(imageUrl),
                                              width: double.minPositive,
                                              height: double.minPositive,
                                            )
                                      : Container(
                                          margin: context.locale == Locale('ar', 'DZ')
                                              ? EdgeInsets.only(left: 10)
                                              : EdgeInsets.only(right: 10),
                                          child: Image.file(file),
                                          width: double.minPositive,
                                          height: double.minPositive,
                                        ),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kMainColor)),
                                ),
                              ),
                        SizedBox(height: 45),
                        ElevatedButton(
                          child: Text(tr('save_button'), style: TextStyle(fontSize: 20)),
                          onPressed: () {
                            save(context);
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
