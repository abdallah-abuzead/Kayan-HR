import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kayan_hr/components/cookbooks/loading.dart';
import 'package:kayan_hr/components/cookbooks/show_snack_bar.dart';
import 'package:kayan_hr/models/employee_model.dart';
import 'package:kayan_hr/models/rule_model.dart';
import 'package:kayan_hr/screens/users/users.dart';
import '../homepage/homepage.dart';
import 'package:kayan_hr/components/cookbooks/spinner.dart';

class EditUserRule extends StatefulWidget {
  const EditUserRule({Key? key}) : super(key: key);
  static const String id = 'edit_user_rule';

  @override
  _EditUserRuleState createState() => _EditUserRuleState();
}

class _EditUserRuleState extends State<EditUserRule> {
  var name, user, empId;
  List<DropdownMenuItem> rulesDropdownItems = [];
  String selectedRuleId = '';

  Future getRules() async {
    final rulesDocs = await RuleModel.getAllRules();
    rulesDropdownItems = rulesDocs.map<DropdownMenuItem<String>>((rule) {
      return DropdownMenuItem<String>(
        child: Text(tr(rule['rule'])),
        value: rule['id'].toString(),
      );
    }).toList();
  }

  void initUI() async {
    await getRules();
    setState(() {
      user = ModalRoute.of(context)!.settings.arguments;
      empId = user['emp_user_id'];
      name = user['name'];
      selectedRuleId = user['rule_id'].toString();
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
        title: Text(tr('edit_user_rule_title')),
      ),
      body: user == null
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
                  margin: EdgeInsets.only(bottom: 5),
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: Text(
                    user['name'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: DropdownButton<dynamic>(
                          value: selectedRuleId,
                          items: rulesDropdownItems,
                          onChanged: (value) {
                            setState(() {
                              selectedRuleId = value;
                            });
                          },
                          hint: Text(tr('select_rule_hint_text')),
                          icon: Icon(Icons.rule, color: Colors.indigoAccent),
                          iconSize: 25,
                          elevation: 50,
                          dropdownColor: Colors.grey.shade200,
                          isExpanded: true,
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 50),
                      ElevatedButton(
                        child: Text(tr('save_button'), style: TextStyle(fontSize: 20)),
                        onPressed: () async {
                          showSpinner(context);
                          await EmployeeModel.updateEmployee(
                            empId,
                            {
                              'rule_id': int.parse(selectedRuleId),
                              'updated_at': DateTime.now().millisecondsSinceEpoch,
                            },
                          );

                          successSnackBar(context, tr('edit_user_rule_indicator'));
                          Navigator.of(context).pushNamedAndRemoveUntil(HomePage.id, (route) => false);
                          Navigator.pushNamed(context, Users.id);
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
