import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kayan_hr/components/cookbooks/loading.dart';
import 'package:kayan_hr/components/cookbooks/show_alert_dialog.dart';
import 'package:kayan_hr/components/cookbooks/show_snack_bar.dart';
import 'package:kayan_hr/constants.dart';
import 'package:kayan_hr/models/employee_model.dart';
import 'package:kayan_hr/models/user_model.dart';
import 'package:kayan_hr/models/vacation_model.dart';
import 'package:kayan_hr/components/cookbooks/spinner.dart';
import 'package:kayan_hr/screens/homepage/employee_homepage.dart';
import 'edit_vacation.dart';

class MyNewVacationsRequests extends StatefulWidget {
  const MyNewVacationsRequests({Key? key}) : super(key: key);
  static const String id = 'my_new_vacations_requests';

  @override
  _MyNewVacationsRequestsState createState() => _MyNewVacationsRequestsState();
}

class _MyNewVacationsRequestsState extends State<MyNewVacationsRequests> {
  List vacationsRequests = [];
  bool hasNewRequests = true;
  var format = DateFormat('dd/MM/yyyy');

  void initUI() async {
    var currentEmployee = await EmployeeModel.getEmployeeByEmail(UserModel.currentUserEmail);
    var requestsDocs = await VacationModel.getMyVacationsRequests(currentEmployee.id);
    setState(() {
      hasNewRequests = requestsDocs.length > 0;
    });
    requestsDocs.forEach((request) async {
      var createdBy = await EmployeeModel.getEmployeeById(request['created_by']);
      var vacation = await VacationModel.getVacation(request['vac_id']);
      setState(() {
        vacationsRequests.add({
          'doc_id': request.id,
          'employee_name': currentEmployee['name'],
          'created_by_name': createdBy['name'],
          'vac_type': vacation['type'],
          ...request.data() as Map,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('my_vacations_requests_title')),
      ),
      body: Container(
        color: Colors.white,
        child: vacationsRequests.isEmpty
            ? !hasNewRequests
                ? loading(tr('you_have_no_vacations_requests'))
                : loading()
            : RawScrollbar(
                thumbColor: kMainColor,
                thickness: 3,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  itemCount: vacationsRequests.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Card(
                        elevation: 4,
                        color: Colors.grey.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: kVacationRequestLabelsWidth,
                                    child: Text(tr('employee_name'), style: kVacationLabelsTextStyle),
                                  ),
                                  Text(kVacationLabelsPostfix, style: kVacationLabelsTextStyle),
                                  Text(
                                    vacationsRequests[i]['employee_name'],
                                    style: kVacationDataTextStyle,
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Container(
                                    width: kVacationRequestLabelsWidth,
                                    child: Text(tr('request_vacation_type'), style: kVacationLabelsTextStyle),
                                  ),
                                  Text(kVacationLabelsPostfix, style: kVacationLabelsTextStyle),
                                  Text(
                                    tr(vacationsRequests[i]['vac_type']),
                                    style: kVacationDataTextStyle,
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Container(
                                    width: kVacationRequestLabelsWidth,
                                    child: Text(tr('start_date'), style: kVacationLabelsTextStyle),
                                  ),
                                  Text(kVacationLabelsPostfix, style: kVacationLabelsTextStyle),
                                  Text(
                                    format
                                        .format(DateTime.parse(vacationsRequests[i]['start_date'].toDate().toString())),
                                    style: kVacationDataTextStyle,
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Container(
                                    width: kVacationRequestLabelsWidth,
                                    child: Text(tr('end_date'), style: kVacationLabelsTextStyle),
                                  ),
                                  Text(kVacationLabelsPostfix, style: kVacationLabelsTextStyle),
                                  Text(
                                    format.format(DateTime.parse(vacationsRequests[i]['end_date'].toDate().toString())),
                                    style: kVacationDataTextStyle,
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Container(
                                    width: kVacationRequestLabelsWidth,
                                    child: Text(tr('no_of_days'), style: kVacationLabelsTextStyle),
                                  ),
                                  Text(kVacationLabelsPostfix, style: kVacationLabelsTextStyle),
                                  Text(
                                    vacationsRequests[i]['no_of_days'].toString(),
                                    style: kVacationLabelsTextStyle.copyWith(color: kMainColor),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Container(
                                    width: kVacationRequestLabelsWidth,
                                    child: Text(tr('request_created_by'), style: kVacationLabelsTextStyle),
                                  ),
                                  Text(kVacationLabelsPostfix, style: kVacationLabelsTextStyle),
                                  Text(
                                    vacationsRequests[i]['created_by_name'],
                                    style: kVacationDataTextStyle,
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  OutlinedButton(
                                    child: Text(tr('edit_button')),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      primary: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(context, EditVacation.id, arguments: vacationsRequests[i]);
                                    },
                                  ),
                                  OutlinedButton(
                                    child: Text(tr('delete_button')),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.red.shade600,
                                      primary: Colors.white,
                                    ),
                                    onPressed: () {
                                      showAlertDialog(
                                        context: context,
                                        title: tr('delete_vacation_request_alert'),
                                        actionButtonOnPressed: () async {
                                          showSpinner(context);
                                          await VacationModel.deleteVacation(vacationsRequests[i]['doc_id']);

                                          dangerSnackBar(context, tr('delete_vacation_request_indicator'));

                                          Navigator.pushNamedAndRemoveUntil(
                                              context, EmployeeHomePage.id, (route) => false);
                                          Navigator.pushNamed(context, MyNewVacationsRequests.id);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
