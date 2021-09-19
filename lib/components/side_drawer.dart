import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:kayan_hr/components/current_user_data.dart';
import 'package:kayan_hr/components/show_alert_dialog.dart';
import 'package:kayan_hr/constants.dart';
import 'package:kayan_hr/models/user_model.dart';
import 'package:kayan_hr/screens/create_new_admin.dart';
import 'package:kayan_hr/screens/edit_my_account.dart';
import 'package:kayan_hr/screens/employees.dart';
import 'package:kayan_hr/screens/new_vacations_requests.dart';
import 'package:kayan_hr/screens/reset_password.dart';
import 'package:kayan_hr/screens/users.dart';
import 'package:kayan_hr/screens/vacations_types.dart';
import 'package:kayan_hr/components/spinner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kayan_hr/screens/homepage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kayan_hr/screens/welcome.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SideDrawer extends StatelessWidget {
  SideDrawer(this.homeContext);
  final BuildContext homeContext;

  late final List<String?> choices;
  late final String? refresh,
      vacationsRequests,
      employees,
      users,
      createNewAdmin,
      vacations,
      englishLanguage,
      arabicLanguage,
      editMyAccount,
      resetPassword,
      deleteMyAccount,
      signOut,
      resetVacations;

  void setChoices() {
    refresh = tr('menu_refresh');
    vacationsRequests = tr('menu_vacations_requests');
    employees = tr('menu_employees');
    users = tr('menu_users');
    createNewAdmin = tr('menu_create_new_admin');
    vacations = tr('menu_vacations_types');
    englishLanguage = 'English';
    arabicLanguage = 'العربية';
    editMyAccount = tr('menu_edit_my_account');
    resetPassword = tr('menu_reset_password');
    deleteMyAccount = tr('menu_delete_my_account');
    signOut = tr('menu_sign_out');
    resetVacations = tr('menu_reset_vacations');
  }

  void initChoices(BuildContext context) {
    setChoices();
    var rule = Provider.of<CurrentUserData>(context).rule;
    if (rule == 1)
      choices = [
        refresh,
        vacations,
        editMyAccount,
        englishLanguage,
        arabicLanguage,
        resetPassword,
        signOut,
      ];
    else if (rule == 2)
      choices = [
        refresh,
        vacationsRequests,
        employees,
        vacations,
        editMyAccount,
        englishLanguage,
        arabicLanguage,
        resetPassword,
        signOut,
      ];
    else if (rule >= 3)
      choices = [
        refresh,
        vacationsRequests,
        employees,
        users,
        createNewAdmin,
        vacations,
        englishLanguage,
        arabicLanguage,
        editMyAccount,
        resetPassword,
        deleteMyAccount,
        signOut,
        resetVacations,
      ];
  }

  Widget getChoiceIcon(String choice) {
    if (choice == refresh)
      return Icon(Icons.refresh, color: Colors.teal);
    else if (choice == vacationsRequests)
      return Icon(Icons.view_list_outlined, color: Colors.teal);
    else if (choice == employees)
      return FaIcon(FontAwesomeIcons.users, color: Colors.teal, size: 18);
    else if (choice == users)
      return FaIcon(FontAwesomeIcons.usersCog, color: Colors.teal, size: 20);
    else if (choice == createNewAdmin)
      return FaIcon(FontAwesomeIcons.userShield, color: Colors.teal, size: 18);
    else if (choice == vacations)
      return Icon(Icons.weekend, color: Colors.teal);
    else if (choice == englishLanguage)
      return FaIcon(FontAwesomeIcons.globeAmericas, color: Colors.teal, size: 18);
    else if (choice == arabicLanguage)
      return FaIcon(FontAwesomeIcons.globeAfrica, color: Colors.teal, size: 20);
    else if (choice == editMyAccount)
      return FaIcon(FontAwesomeIcons.userEdit, color: Colors.teal, size: 18);
    else if (choice == resetPassword)
      return FaIcon(FontAwesomeIcons.userLock, color: Colors.teal, size: 18);
    else if (choice == deleteMyAccount)
      return FaIcon(FontAwesomeIcons.userTimes, color: Colors.teal, size: 18);
    else if (choice == signOut)
      return Icon(Icons.logout, color: Colors.teal);
    else
      return Icon(Icons.reset_tv, color: Colors.teal);
  }

  void getChoiceAction(BuildContext context, String choice) async {
    if (choice == refresh)
      Navigator.of(context).pushReplacementNamed(ModalRoute.of(context)?.settings.name as String);
    else if (choice == vacationsRequests)
      Navigator.pushNamed(context, NewVacationsRequests.id);
    else if (choice == employees)
      Navigator.pushNamed(context, Employees.id);
    else if (choice == users)
      Navigator.pushNamed(context, Users.id);
    else if (choice == createNewAdmin)
      Navigator.pushNamed(context, CreateNewAdmin.id);
    else if (choice == vacations)
      Navigator.pushNamed(context, VacationsTypes.id);
    else if (choice == englishLanguage)
      await context.setLocale(Locale('en', 'US'));
    else if (choice == arabicLanguage)
      await context.setLocale(Locale('ar', 'DZ'));
    else if (choice == editMyAccount)
      Navigator.pushNamed(context, EditMyAccount.id);
    else if (choice == resetPassword)
      Navigator.pushNamed(context, ResetPassword.id);
    else if (choice == deleteMyAccount)
      deleteMyAccountDialog(homeContext);
    else if (choice == signOut) {
      showSpinner(context);
      await UserModel.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil(Welcome.id, (route) => false);
    } else
      resetVacationsDialog(homeContext);
  }

  void deleteMyAccountDialog(BuildContext context) {
    showAlertDialog(
      context: context,
      title: tr('delete_my_account_alert'),
      actionButtonOnPressed: () async {
        await UserModel.deleteUser(UserModel.currentUserEmail);
        Navigator.of(context).pushNamedAndRemoveUntil(Welcome.id, (route) => false);
      },
    );
  }

  void resetVacationsDialog(BuildContext context) {
    showAlertDialog(
      context: context,
      title: tr('reset_all_vacations_alert'),
      actionButtonText: tr('reset_button'),
      actionButtonOnPressed: () async {
        Navigator.of(context).pop();
        showAlertDialog(
          context: context,
          title: tr('delete_all_vacations_alert'),
          actionButtonOnPressed: () async {
            Navigator.of(context).pop();
            showSpinner(context);
            await FirebaseFirestore.instance.collection('employee_vacation').get().then((vacs) {
              vacs.docs.forEach((vac) async {
                vac.reference.delete();
              });
            });
            print('all vacations deleted');
            Navigator.of(context).pushNamedAndRemoveUntil(HomePage.id, (route) => false);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map currentUser = Provider.of<CurrentUserData>(context).currentUser;
    initChoices(context);

    return Drawer(
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 30, bottom: 10),
            decoration: BoxDecoration(color: kMainColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    tr('welcome') + ' ' + currentUser['name'].split(' ')[0],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                  ),
                  leading: currentUser['image_url'] == ''
                      ? CircleAvatar(radius: 30, backgroundImage: AssetImage('images/avatar.png'))
                      : CircleAvatar(radius: 30, backgroundImage: NetworkImage(currentUser['image_url'])),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.rule, size: 20, color: Colors.blueGrey.shade100),
                    SizedBox(width: 15),
                    Text(tr(currentUser['rule_name']), style: kUserDataTextStyle),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.email, size: 20, color: Colors.blueGrey.shade100),
                    SizedBox(width: 15),
                    Text(currentUser['email'], style: kUserDataTextStyle),
                  ],
                ),
                currentUser['phone'] == ''
                    ? Container()
                    : Row(
                        children: [
                          Icon(Icons.phone, size: 20, color: Colors.blueGrey.shade100),
                          SizedBox(width: 15),
                          Text(currentUser['phone'], style: kUserDataTextStyle),
                        ],
                      ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 15),
              itemCount: choices.length,
              separatorBuilder: (context, i) {
                return Divider(
                  thickness: 2,
                  height: 0,
                );
              },
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text('${choices[i]}', style: TextStyle(fontSize: 16)),
                  trailing: getChoiceIcon('${choices[i]}'),
                  contentPadding: EdgeInsets.symmetric(horizontal: 5),
                  hoverColor: Colors.grey.shade300,
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    Navigator.pop(context);
                    getChoiceAction(context, choices[i].toString());
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
