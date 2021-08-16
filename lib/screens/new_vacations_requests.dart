import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kayan_hr/components/loading.dart';
import 'package:kayan_hr/components/show_alert_dialog.dart';
import 'package:kayan_hr/constants.dart';
import 'package:kayan_hr/models/employee_model.dart';
import 'package:kayan_hr/models/user_model.dart';
import 'package:kayan_hr/models/vacation_model.dart';
import 'package:kayan_hr/components/spinner.dart';
import 'edit_vacation.dart';
import 'homepage.dart';

class NewVacationsRequests extends StatefulWidget {
  const NewVacationsRequests({Key? key}) : super(key: key);
  static const String id = 'new_vacations_requests';

  @override
  _NewVacationsRequestsState createState() => _NewVacationsRequestsState();
}

class _NewVacationsRequestsState extends State<NewVacationsRequests> {
  List vacationsRequests = [];
  bool hasNewRequests = true;
  var format = DateFormat('dd/MM/yyyy');

  void initUI() async {
    var requestsDocs = await VacationModel.getAllNewVacationsRequests();
    setState(() {
      hasNewRequests = requestsDocs.length > 0;
    });
    requestsDocs.forEach((request) async {
      var employee = await EmployeeModel.getEmployeeById(request['emp_id']);
      var createdBy = await EmployeeModel.getEmployeeById(request['created_by']);
      setState(() {
        vacationsRequests.add({
          'doc_id': request.id,
          'employee_name': employee['name'],
          'created_by_name': createdBy['name'],
          ...request.data() as Map,
        });
      });
    });
  }

  String getVacationName(int vacId) {
    switch (vacId) {
      case 1:
        return context.locale.toString() == 'ar_DZ' ? 'سنوية' : 'annual';
      case 2:
        return context.locale.toString() == 'ar_DZ' ? 'عارضة' : 'casual';
      case 3:
        return context.locale.toString() == 'ar_DZ' ? 'مرضى' : 'sick';
      case 4:
        return context.locale.toString() == 'ar_DZ' ? 'منحة' : 'grant';
      case 5:
        return context.locale.toString() == 'ar_DZ' ? 'Rotation' : 'rotation';
      default:
        return '';
    }
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
        title: Text(tr('vacations_requests_title')),
      ),
      body: Container(
        color: Colors.white,
        child: vacationsRequests.isEmpty
            ? !hasNewRequests
                ? loading(tr('there_are_no_vacations_requests'))
                : loading()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            tr('no_vacations_requests'),
                            style: kVacationLabelsTextStyle.copyWith(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          vacationsRequests.length.toString(),
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
                                          getVacationName(vacationsRequests[i]['vac_id']),
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
                                          format.format(
                                              DateTime.parse(vacationsRequests[i]['start_date'].toDate().toString())),
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
                                          format.format(
                                              DateTime.parse(vacationsRequests[i]['end_date'].toDate().toString())),
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
                                          child: Text(tr('accept_button')),
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            primary: Colors.white,
                                          ),
                                          onPressed: () async {
                                            showSpinner(context);
                                            var currentEmployee =
                                                await EmployeeModel.getEmployeeByEmail(UserModel.currentUserEmail);
                                            await VacationModel.updateVacation(
                                              vacationsRequests[i]['doc_id'],
                                              {
                                                'status_id': 2,
                                                'updated_by': currentEmployee.id,
                                                'updated_at': DateTime.now().millisecondsSinceEpoch,
                                              },
                                            );
                                            Navigator.pushNamedAndRemoveUntil(context, HomePage.id, (route) => false);
                                            Navigator.pushNamed(context, NewVacationsRequests.id);
                                          },
                                        ),
                                        OutlinedButton(
                                          child: Text(tr('edit_button')),
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            primary: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.pushNamed(context, EditVacation.id,
                                                arguments: vacationsRequests[i]);
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
                                                Navigator.pushNamedAndRemoveUntil(
                                                    context, HomePage.id, (route) => false);
                                                Navigator.pushNamed(context, NewVacationsRequests.id);
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
                ],
              ),
      ),
    );
  }
}
