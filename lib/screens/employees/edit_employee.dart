import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kayan_hr/components/cookbooks/loading.dart';
import 'package:kayan_hr/components/cookbooks/show_snack_bar.dart';
import 'package:kayan_hr/components/cookbooks/validation_error.dart';
import 'package:kayan_hr/models/employee_model.dart';
import 'package:kayan_hr/models/user_model.dart';
import 'package:kayan_hr/screens/employees/employees.dart';
import '../homepage/homepage.dart';
import 'package:kayan_hr/components/cookbooks/spinner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:kayan_hr/constants.dart';

class EditEmployee extends StatefulWidget {
  const EditEmployee({Key? key}) : super(key: key);
  static const String id = 'edit_employee';

  @override
  _EditEmployeeState createState() => _EditEmployeeState();
}

class _EditEmployeeState extends State<EditEmployee> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var name, oldEmail, newEmail, empId;
  bool _showEmailError = false;
  late File file;
  final ImagePicker picker = ImagePicker();
  String pickedImagePath = '';
  String imageUrl = '';
  var imageName;

  void initUI(BuildContext context) {
    setState(() {
      final employee = ModalRoute.of(context)!.settings.arguments as QueryDocumentSnapshot;
      empId = employee.id;
      name = employee['name'];
      oldEmail = employee['email'];
      imageUrl = employee['image_url'];
    });
  }

  @override
  Widget build(BuildContext context) {
    initUI(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr('edit_employee_title')),
      ),
      body: empId == null
          ? loading()
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 30),
                  child: Center(
                    child: Image.asset(
                      'images/logo.png',
                      scale: 3,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
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
                            hintText: tr('name_hint_text'),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(width: 1),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          initialValue: oldEmail,
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
                        SizedBox(height: 10),
                        TextFormField(
                          onTap: () async {
                            final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);
                            if (pickedImage != null) {
                              setState(() {
                                file = File(pickedImage.path);
                                pickedImagePath = pickedImage.path;
                              });
                              imageName = '${DateTime.now().millisecondsSinceEpoch}-${basename(pickedImage.path)}';
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
                        SizedBox(height: 50),
                        ElevatedButton(
                          child: Text(tr('save_button'), style: TextStyle(fontSize: 20)),
                          onPressed: () async {
                            var formData = formKey.currentState;
                            if (formData!.validate()) {
                              formData.save();
                              showSpinner(context);
                              if (newEmail != oldEmail && await EmployeeModel.isEmailExists(newEmail)) {
                                setState(() {
                                  _showEmailError = true;
                                  Navigator.of(context).pop();
                                });
                              } else {
                                // update employee
                                if (pickedImagePath != '') {
                                  await EmployeeModel.deleteEmployeeImage(imageUrl);
                                  imageUrl = await EmployeeModel.storeEmployeeImage(imageName, file);
                                }
                                await EmployeeModel.updateEmployee(
                                  empId,
                                  {
                                    'name': name,
                                    'email': newEmail,
                                    'image_url': imageUrl,
                                    'updated_at': DateTime.now().millisecondsSinceEpoch,
                                  },
                                );
                                // update firebase user email
                                UserModel.updateUserEmailOnFirebase(oldEmail, newEmail);
                                // update user data
                                final user = await UserModel.getUserByEmail(oldEmail);
                                await UserModel.updateUser(
                                  user.id,
                                  {'email': newEmail, 'updated_at': DateTime.now().millisecondsSinceEpoch},
                                );

                                successSnackBar(context, tr('edit_employee_indicator'));
                                Navigator.of(context).pushNamedAndRemoveUntil(HomePage.id, (route) => false);
                                Navigator.pushNamed(context, Employees.id);
                              }
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
