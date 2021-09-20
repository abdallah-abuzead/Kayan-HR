import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kayan_hr/components/cookbooks/loading.dart';
import 'package:kayan_hr/components/cookbooks/show_alert_dialog.dart';
import 'package:kayan_hr/components/cookbooks/show_snack_bar.dart';
import 'package:kayan_hr/constants.dart';
import 'package:kayan_hr/models/user_model.dart';
import 'package:kayan_hr/components/cookbooks/spinner.dart';
import 'package:kayan_hr/screens/users/edit_user_rule.dart';
import '../homepage/homepage.dart';
import 'package:kayan_hr/models/employee_model.dart';

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);
  static const String id = 'users';

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  List users = [];

  Widget userCircleAvatar(var imageUrl) {
    if (imageUrl == '')
      return CircleAvatar(radius: 30, backgroundImage: AssetImage('images/avatar.png'));
    else
      return CircleAvatar(radius: 30, backgroundImage: NetworkImage(imageUrl));
  }

  Widget userPatch(var ruleId) {
    switch (ruleId) {
      case 1:
        return FaIcon(FontAwesomeIcons.userAlt, color: Colors.teal.shade400, size: 19);
      // return Text('👨🏻‍💻', style: TextStyle(fontSize: 22));
      case 2:
        return FaIcon(FontAwesomeIcons.userTie, color: Colors.teal.shade800);
      // return Text('👨🏻‍💼', style: TextStyle(fontSize: 22));
      case 3:
        return FaIcon(FontAwesomeIcons.userShield, color: Colors.green.shade600);
      // return Icon(Icons.admin_panel_settings_outlined, color: Colors.indigoAccent, size: 30);
      default:
        return Text('');
    }
  }

  void initUI() async {
    var usersDocs = await UserModel.getAllUsers();
    usersDocs.forEach((userDoc) async {
      final employee = await EmployeeModel.getEmployeeByEmail(userDoc['email']);
      setState(() {
        users.add({
          'user_id': userDoc.id,
          'emp_user_id': employee.id,
          ...userDoc.data() as Map,
          'image_url': employee['image_url'],
          'rule_id': employee['rule_id'],
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initUI();
  }

  @override
  Widget build(BuildContext context) {
    if (users.isNotEmpty) {
      users.sort((user1, user2) {
        return (user2['rule_id']).compareTo(user1['rule_id']);
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('users_title')),
      ),
      body: Container(
        color: Colors.white,
        child: users.isEmpty
            ? loading()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            tr('no_of_users'),
                            style: kVacationLabelsTextStyle.copyWith(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          users.length.toString(),
                          style: kVacationLabelsTextStyle.copyWith(fontSize: 16, color: kMainColor),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.teal.shade600,
                    height: 0,
                    thickness: 3,
                  ),
                  Expanded(
                    child: RawScrollbar(
                      thumbColor: kMainColor,
                      thickness: 3,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        itemCount: users.length,
                        itemBuilder: (context, i) {
                          return Card(
                            elevation: 4,
                            color: Colors.teal.shade50,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(8),
                              leading: userCircleAvatar(users[i]['image_url']),
                              title: Text(
                                users[i]['name'],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(users[i]['email']),
                                    SizedBox(height: 5),
                                    Text(users[i]['phone']),
                                  ],
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Flexible(flex: 2, child: userPatch(users[i]['rule_id'])),
                                  SizedBox(height: 8),
                                  users[i]['rule_id'] >= 3
                                      ? Container(width: double.minPositive)
                                      : Expanded(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Icon(Icons.rule, color: Colors.indigoAccent),
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    EditUserRule.id,
                                                    arguments: users[i],
                                                  );
                                                },
                                              ),
                                              SizedBox(width: 15),
                                              InkWell(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Icon(Icons.delete, color: Colors.indigoAccent.shade100),
                                                onTap: () {
                                                  showAlertDialog(
                                                    context: context,
                                                    title: tr('delete_user_alert'),
                                                    actionButtonOnPressed: () async {
                                                      Navigator.of(context).pop();
                                                      showSpinner(context);
                                                      await UserModel.deleteUser(users[i]['email']);

                                                      dangerSnackBar(context, tr('delete_user_indicator'));

                                                      Navigator.of(context)
                                                          .pushNamedAndRemoveUntil(HomePage.id, (route) => false);
                                                      Navigator.pushNamed(context, Users.id);
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
