import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kayan_hr/components/current_user_data.dart';
import 'package:kayan_hr/components/loading.dart';
import 'package:kayan_hr/components/show_alert_dialog.dart';
import 'package:kayan_hr/components/show_snack_bar.dart';
import 'package:kayan_hr/constants.dart';
import 'package:kayan_hr/models/employee_model.dart';
import 'package:kayan_hr/screens/edit_employee.dart';
import 'package:kayan_hr/components/spinner.dart';
import 'package:provider/provider.dart';
import 'homepage.dart';
import 'package:kayan_hr/screens/employee_vacations.dart';

class Employees extends StatefulWidget {
  const Employees({Key? key}) : super(key: key);
  static const String id = 'employees';

  @override
  _EmployeesState createState() => _EmployeesState();
}

class _EmployeesState extends State<Employees> {
  List employees = [];

  Widget employeeCircleAvatar(var imageUrl) {
    if (imageUrl == '')
      return CircleAvatar(radius: 30, backgroundImage: AssetImage('images/avatar.png'));
    else
      return CircleAvatar(radius: 30, backgroundImage: NetworkImage(imageUrl));
  }

  void initUI() async {
    var employeesDocs = await EmployeeModel.getAllEmployees();
    setState(() {
      employees = employeesDocs;
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
      appBar: AppBar(
        title: Text(tr('employees_title')),
      ),
      body: Container(
        color: Colors.white,
        child: employees.isEmpty
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
                            tr('no_of_employees'),
                            style: kVacationLabelsTextStyle.copyWith(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          employees.length.toString(),
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
                        itemCount: employees.length,
                        itemBuilder: (context, i) {
                          return Card(
                            elevation: 4,
                            color: Colors.teal.shade50,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(8),
                              leading: employeeCircleAvatar(employees[i]['image_url']),
                              onTap: () {
                                Navigator.pushNamed(context, EmployeeVacations.id, arguments: employees[i]);
                              },
                              title: Text(
                                employees[i]['name'],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(employees[i]['email']),
                              ),
                              trailing: Provider.of<CurrentUserData>(context).rule < 3
                                  ? Container(width: double.minPositive)
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            InkWell(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Icon(Icons.edit, color: Colors.teal.shade700),
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  EditEmployee.id,
                                                  arguments: employees[i],
                                                );
                                              },
                                            ),
                                            SizedBox(width: 15),
                                            InkWell(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Icon(Icons.delete, color: Colors.teal.shade700),
                                              onTap: () {
                                                showAlertDialog(
                                                  context: context,
                                                  title: tr('delete_employee_alert'),
                                                  actionButtonOnPressed: () async {
                                                    Navigator.of(context).pop();
                                                    showSpinner(context);
                                                    await EmployeeModel.deleteEmployee(
                                                        employees[i].id, employees[i]['image_url']);

                                                    dangerSnackBar(context, tr('delete_employee_indicator'));

                                                    Navigator.of(context)
                                                        .pushNamedAndRemoveUntil(HomePage.id, (route) => false);
                                                    Navigator.pushNamed(context, Employees.id);
                                                  },
                                                );
                                              },
                                            ),
                                          ],
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
