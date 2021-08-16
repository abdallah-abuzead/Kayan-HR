import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kayan_hr/components/current_user_rule_data.dart';
import 'package:kayan_hr/components/loading.dart';
import 'package:kayan_hr/components/show_alert_dialog.dart';
import 'package:kayan_hr/components/spinner.dart';
import 'package:kayan_hr/constants.dart';
import 'package:kayan_hr/models/employee_model.dart';
import 'package:kayan_hr/models/vacation_model.dart';
import 'package:kayan_hr/screens/edit_vacation.dart';
import 'package:kayan_hr/screens/employee_vacations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class Vacations extends StatefulWidget {
  Vacations({required this.empId, required this.vacId});
  final empId;
  final vacId;
  @override
  _VacationsState createState() => _VacationsState();
}

class _VacationsState extends State<Vacations> {
  List<Map> vacations = [];
  bool hasVacations = true;
  var format = DateFormat('dd/MM/yyyy');
  num totalUsedDays = 0;

  void getEmployeeVacations() async {
    final vacationsDocs = await VacationModel.getEmployeeVacations(widget.empId, widget.vacId);
    setState(() {
      hasVacations = vacationsDocs.length > 0;
    });
    vacationsDocs.forEach((vacation) {
      final vacationData = vacation.data() as Map;
      setState(() {
        totalUsedDays += vacationData['no_of_days'];
        vacations.add({
          'doc_id': vacation.id,
          ...vacationData,
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

  String getTheRestDays(int vacId) {
    switch (vacId) {
      case 1:
        return '${21 - totalUsedDays}';
      case 2:
        return '${7 - totalUsedDays}';
      case 3:
        return '--';
      case 4:
        return '--';
      case 5:
        return '--';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    getEmployeeVacations();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(5),
      child: vacations.isEmpty
          ? !hasVacations
              ? context.locale.toString() == 'ar_DZ'
                  ? loading('لا يوجد أجازات ${getVacationName(widget.vacId)}')
                  : loading('This Employee has no ${getVacationName(widget.vacId)} vacations.')
              : loading()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 10, bottom: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                tr('total_used_days'),
                                style: kVacationLabelsTextStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '$totalUsedDays',
                              style: kVacationLabelsTextStyle.copyWith(color: kMainColor),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                tr('the_rest'),
                                style: kVacationLabelsTextStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              getTheRestDays(widget.vacId),
                              style: kVacationLabelsTextStyle.copyWith(color: kMainColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RawScrollbar(
                    thumbColor: kMainColor,
                    thickness: 3,
                    child: ListView.builder(
                      itemCount: vacations.length,
                      itemBuilder: (context, i) {
                        return Card(
                          elevation: 4,
                          color: Colors.teal.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: kVacationLabelsWidth,
                                          child: Text(tr('start_date'), style: kVacationLabelsTextStyle),
                                        ),
                                        Text(kVacationLabelsPostfix, style: kVacationLabelsTextStyle),
                                        Text(
                                          format.format(DateTime.parse(vacations[i]['start_date'].toDate().toString())),
                                          style: kVacationDataTextStyle,
                                        ),
                                      ],
                                    ),
                                    Provider.of<CurrentUserRule>(context).rule < 3
                                        ? Container(width: double.minPositive)
                                        : Row(
                                            children: [
                                              InkWell(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Icon(Icons.edit, color: Colors.teal.shade700),
                                                onTap: () {
                                                  Navigator.pushNamed(context, EditVacation.id,
                                                      arguments: vacations[i]);
                                                },
                                              ),
                                              SizedBox(width: 15),
                                              InkWell(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Icon(Icons.delete, color: Colors.teal.shade700),
                                                onTap: () {
                                                  showAlertDialog(
                                                    context: context,
                                                    title: tr('delete_vacation_alert'),
                                                    actionButtonOnPressed: () async {
                                                      Navigator.of(context).pop();
                                                      showSpinner(context);
                                                      await VacationModel.deleteVacation(vacations[i]['doc_id']);
                                                      Navigator.of(context).pop();
                                                      Navigator.pushReplacementNamed(
                                                        context,
                                                        EmployeeVacations.id,
                                                        arguments: await EmployeeModel.getEmployeeById(widget.empId),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(
                                      width: kVacationLabelsWidth,
                                      child: Text(tr('end_date'), style: kVacationLabelsTextStyle),
                                    ),
                                    Text(kVacationLabelsPostfix, style: kVacationLabelsTextStyle),
                                    Text(
                                      format.format(DateTime.parse(vacations[i]['end_date'].toDate().toString())),
                                      style: kVacationDataTextStyle,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(
                                      width: kVacationLabelsWidth,
                                      child: Text(tr('no_of_days'), style: kVacationLabelsTextStyle),
                                    ),
                                    Text(kVacationLabelsPostfix, style: kVacationLabelsTextStyle),
                                    Text(
                                      vacations[i]['no_of_days'].toString(),
                                      style: kVacationLabelsTextStyle.copyWith(color: kMainColor),
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
    );
  }
}
