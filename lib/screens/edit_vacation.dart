import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kayan_hr/components/spinner.dart';
import 'package:kayan_hr/components/validation_error.dart';
import 'package:kayan_hr/models/employee_model.dart';
import 'package:kayan_hr/models/user_model.dart';
import 'package:kayan_hr/models/vacation_model.dart';
import 'package:kayan_hr/screens/employee_homepage.dart';
import 'package:kayan_hr/screens/homepage.dart';
import 'package:kayan_hr/screens/my_new_vacations_requests.dart';
import 'package:kayan_hr/screens/new_vacations_requests.dart';
import 'employee_vacations.dart';
import 'package:kayan_hr/constants.dart';
import 'package:intl/intl.dart';

class EditVacation extends StatefulWidget {
  const EditVacation({Key? key}) : super(key: key);
  static String id = 'edit_vacation';

  @override
  _EditVacationState createState() => _EditVacationState();
}

class _EditVacationState extends State<EditVacation> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<DropdownMenuItem> vacationsDropdownItems = [];
  String selectedEmployeeId = '';
  String selectedVacationId = '';
  DateTime? initStartDate;
  DateTime? initEndDate;
  DateTime? startDate;
  DateTime? endDate;
  bool showDateError = false;
  String dateErrorMessage = '';
  var format = DateFormat('dd/MM/yyyy');
  String employeeName = '';
  String employeeId = '';
  late final args;

  void getVacations() async {
    final vacationsTypesDocs = await VacationModel.getVacationsTypes();
    vacationsDropdownItems = vacationsTypesDocs.map<DropdownMenuItem<String>>((vacation) {
      return DropdownMenuItem<String>(
        child: Text(tr(vacation.data()['type'])),
        value: vacation.data()['id'].toString(),
      );
    }).toList();
  }

  void initUI() async {
    args = ModalRoute.of(context)!.settings.arguments as Map;
    final employeeDoc = await EmployeeModel.getEmployeeById(args['emp_id']);
    setState(() {
      employeeName = employeeDoc['name'];
      employeeId = args['emp_id'];
      selectedVacationId = args['vac_id'].toString();
      initStartDate = DateTime.parse(args['start_date'].toDate().toString());
      initEndDate = DateTime.parse(args['end_date'].toDate().toString());
      startDate = DateTime.parse(args['start_date'].toDate().toString());
      endDate = DateTime.parse(args['end_date'].toDate().toString());
    });
  }

  @override
  void initState() {
    super.initState();
    getVacations();
    Future.delayed(Duration.zero, () {
      initUI();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr('edit_vacation_title')),
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
            margin: EdgeInsets.only(bottom: 5),
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Text(
              employeeName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade600,
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
                    child: Text(tr('save_button'), style: TextStyle(fontSize: 20)),
                    onPressed: () async {
                      setState(() {
                        showDateError = false;
                      });
                      if (selectedVacationId == '2' || selectedVacationId == '5') endDate = startDate;
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
                          final currentEmployee = await EmployeeModel.getEmployeeByEmail(UserModel.currentUserEmail);
                          await VacationModel.updateVacation(
                            args['doc_id'],
                            {
                              'vac_id': int.parse(selectedVacationId),
                              'start_date': startDate,
                              'end_date': endDate,
                              'no_of_days': noOfDays,
                              'updated_by': currentEmployee.id,
                              'updated_at': DateTime.now().millisecondsSinceEpoch,
                            },
                          );
                          if (args['status_id'] == 2) {
                            // admin edited in a registered vacation
                            Navigator.of(context).pushNamedAndRemoveUntil(HomePage.id, (route) => false);
                            Navigator.pushNamed(
                              context,
                              EmployeeVacations.id,
                              arguments: await EmployeeModel.getEmployeeById(employeeId),
                            );
                          } else {
                            if (currentEmployee.id == employeeId) {
                              // current user edited in his vacation request
                              Navigator.of(context).pushNamedAndRemoveUntil(EmployeeHomePage.id, (route) => false);
                              Navigator.pushNamed(context, MyNewVacationsRequests.id);
                            } else {
                              // admin or moderator edited in an employee vacation request
                              Navigator.of(context).pushNamedAndRemoveUntil(HomePage.id, (route) => false);
                              Navigator.pushNamed(context, NewVacationsRequests.id);
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
  }
}
