import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kayan_hr/components/current_user_data.dart';
import 'package:kayan_hr/components/show_snack_bar.dart';
import 'package:kayan_hr/components/spinner.dart';
import 'package:kayan_hr/components/employees_checkbox_list.dart';
import 'package:kayan_hr/components/selected_employees_data.dart';
import 'package:kayan_hr/components/validation_error.dart';
import 'package:kayan_hr/models/employee_model.dart';
import 'package:kayan_hr/models/user_model.dart';
import 'package:kayan_hr/models/vacation_model.dart';
import 'package:kayan_hr/screens/employee_homepage.dart';
import 'package:kayan_hr/screens/new_vacations_requests.dart';
import 'package:provider/provider.dart';
import 'homepage.dart';
import 'package:kayan_hr/constants.dart';
import 'package:intl/intl.dart';

class RegisterVacation extends StatefulWidget {
  const RegisterVacation({Key? key}) : super(key: key);
  static String id = 'register_vacation';

  @override
  _RegisterVacationState createState() => _RegisterVacationState();
}

class _RegisterVacationState extends State<RegisterVacation> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<DropdownMenuItem> employeesDropdownItems = [];
  List<DropdownMenuItem> vacationsDropdownItems = [];
  List<QueryDocumentSnapshot> employeesDocs = [];
  String selectedEmployeeId = '';
  String selectedVacationId = '';
  DateTime? initStartDate = DateTime.now();
  DateTime? initEndDate = DateTime.now();
  DateTime? startDate;
  DateTime? endDate;
  bool showDateError = false;
  String dateErrorMessage = '';
  var format = DateFormat('dd/MM/yyyy');
  late DocumentSnapshot employee;

  Future getEmployees() async {
    employeesDocs = await EmployeeModel.getAllEmployees();
    employeesDropdownItems = employeesDocs.map<DropdownMenuItem<String>>((employee) {
      return DropdownMenuItem<String>(
        child: Text((employee.data() as Map)['name']),
        value: employee.id,
      );
    }).toList();
    setState(() {
      selectedEmployeeId = employeesDropdownItems[0].value;
    });
  }

  Future getVacations() async {
    final vacationsTypesDocs = await VacationModel.getVacationsTypes();
    vacationsDropdownItems = vacationsTypesDocs.map<DropdownMenuItem<String>>((vacation) {
      return DropdownMenuItem<String>(
        child: Text(tr(vacation.data()['type'])),
        value: vacation.data()['id'].toString(),
      );
    }).toList();
    setState(() {
      selectedVacationId = vacationsDropdownItems[0].value;
    });
  }

  Future registerVacation(BuildContext context, String empId, int noOfDays, var statusId) async {
    final currentEmployee = await EmployeeModel.getEmployeeByEmail(UserModel.currentUserEmail);
    await VacationModel.addVacation({
      'emp_id': empId,
      'vac_id': int.parse(selectedVacationId),
      'start_date': startDate,
      'end_date': endDate,
      'no_of_days': noOfDays,
      'status_id': statusId,
      'created_by': currentEmployee.id,
      'updated_by': currentEmployee.id,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await getEmployees();
      await getVacations();
    });
  }

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments;
    if (args != null) {
      employee = args as DocumentSnapshot;
      selectedEmployeeId = employee.id;
    }

    return ChangeNotifierProvider<SelectedEmployeesData>(
      create: (context) => SelectedEmployeesData(),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(tr('register_vacation_title')),
          ),
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 30),
                child: Center(
                  child: Image.asset(
                    'images/logo.png',
                    scale: 3,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 20, right: 20, left: 20),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      args != null
                          ? Container(
                              margin: EdgeInsets.only(bottom: 5),
                              padding: EdgeInsets.all(10),
                              alignment: Alignment.center,
                              child: Text(
                                employee['name'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade600,
                                ),
                              ),
                            )
                          : selectedVacationId == '5'
                              ? Container(
                                  height: 350,
                                  margin: EdgeInsets.only(bottom: 15),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 2),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: EmployeesCheckboxList(employees: employeesDocs),
                                )
                              : Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  alignment: Alignment.center,
                                  child: DropdownButton<dynamic>(
                                    value: selectedEmployeeId,
                                    items: employeesDropdownItems,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedEmployeeId = value;
                                      });
                                    },
                                    hint: Text(tr('select_employee_hint_text')),
                                    icon: Icon(Icons.person),
                                    iconSize: 25,
                                    elevation: 50,
                                    dropdownColor: Colors.grey.shade200,
                                    isExpanded: true,
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                ),
                      Container(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: DropdownButton<dynamic>(
                          value: selectedVacationId,
                          items: vacationsDropdownItems,
                          onChanged: (value) {
                            setState(() {
                              selectedVacationId = value;
                            });
                          },
                          hint: Text(tr('select_vacation_hint_text')),
                          icon: Icon(Icons.weekend),
                          iconSize: 25,
                          elevation: 50,
                          dropdownColor: Colors.grey.shade200,
                          isExpanded: true,
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(tr('start_date'), style: TextStyle(fontSize: 18)),
                      TextFormField(
                        onTap: () async {
                          startDate = await showDatePicker(
                              context: context,
                              initialDate: initStartDate as DateTime,
                              firstDate: DateTime(2001),
                              lastDate: DateTime(2050),
                              builder: (context, child) {
                                return Theme(data: kShowDatePickerTheme, child: child as Widget);
                              });
                          if (startDate != null && startDate != initStartDate) {
                            setState(() {
                              initStartDate = startDate;
                            });
                          }
                        },
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: (startDate != null ? format.format(startDate as DateTime) : '').toString(),
                          suffixIcon: Icon(Icons.calendar_today, color: Colors.grey.shade700),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kMainColor)),
                        ),
                      ),
                      selectedVacationId == '2' || selectedVacationId == '5'
                          ? Container()
                          : Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Text(tr('end_date'), style: TextStyle(fontSize: 18)),
                                  TextFormField(
                                    onTap: () async {
                                      endDate = await showDatePicker(
                                          context: context,
                                          initialDate: initEndDate as DateTime,
                                          firstDate: DateTime(2001),
                                          lastDate: DateTime(2050),
                                          builder: (context, child) {
                                            return Theme(data: kShowDatePickerTheme, child: child as Widget);
                                          });
                                      if (endDate != null && endDate != initEndDate) {
                                        setState(() {
                                          initEndDate = endDate;
                                        });
                                      }
                                    },
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      hintText: (endDate != null ? format.format(endDate as DateTime) : '').toString(),
                                      suffixIcon: Icon(Icons.calendar_today, color: Colors.grey.shade700),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kMainColor)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ValidationError(errorMessage: dateErrorMessage, visible: showDateError),
                      SizedBox(height: 60),
                      ElevatedButton(
                        child: Text(tr('register_button'), style: TextStyle(fontSize: 20)),
                        onPressed: () async {
                          setState(() {
                            showDateError = false;
                          });
                          if (selectedVacationId == '2' || selectedVacationId == '5') {
                            endDate = startDate;
                          }
                          if (startDate == null || endDate == null) {
                            setState(() {
                              showDateError = true;
                              dateErrorMessage = tr('empty_date_error_message');
                            });
                          } else {
                            int noOfDays = endDate!.difference(startDate!).inDays + 1;
                            if (noOfDays <= 0) {
                              setState(() {
                                showDateError = true;
                                dateErrorMessage = tr('end_date_error_message');
                              });
                            } else {
                              showSpinner(context);
                              var rule = Provider.of<CurrentUserData>(context, listen: false).rule;

                              // register vacation
                              if (selectedVacationId == '5' && args == null) {
                                List<String> selectedEmployeesIds =
                                    Provider.of<SelectedEmployeesData>(context, listen: false).selectedEmployeesIds;
                                selectedEmployeesIds.forEach((employeeId) async {
                                  await registerVacation(context, employeeId, noOfDays, rule >= 3 ? 2 : 1);
                                });
                              } else {
                                await registerVacation(context, selectedEmployeeId, noOfDays, rule >= 3 ? 2 : 1);
                              }

                              Navigator.pop(context);

                              successSnackBar(context, tr('register_vacation_indicator'));

                              // Navigate to...
                              if (rule >= 3)
                                Navigator.of(context).pushNamedAndRemoveUntil(HomePage.id, (route) => false);
                              else if (rule == 1)
                                Navigator.of(context).pushNamedAndRemoveUntil(EmployeeHomePage.id, (route) => false);
                              else {
                                final currentEmployee =
                                    await EmployeeModel.getEmployeeByEmail(UserModel.currentUserEmail);
                                if (selectedEmployeeId == currentEmployee.id)
                                  Navigator.of(context).pushNamedAndRemoveUntil(EmployeeHomePage.id, (route) => false);
                                else {
                                  Navigator.of(context).pushNamedAndRemoveUntil(HomePage.id, (route) => false);
                                  Navigator.of(context).pushNamed(NewVacationsRequests.id);
                                }
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
