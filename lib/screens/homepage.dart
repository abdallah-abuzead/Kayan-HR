import 'package:flutter/cupertino.dart';
import 'package:kayan_hr/components/current_user_rule_data.dart';
import 'package:kayan_hr/components/loading.dart';
import 'package:kayan_hr/models/employee_model.dart';
import 'package:kayan_hr/models/vacation_model.dart';
import 'package:kayan_hr/screens/add_employee.dart';
import 'package:flutter/material.dart';
import 'package:kayan_hr/screens/employee_homepage.dart';
import 'package:provider/provider.dart';
import 'register_vacation.dart';
import 'package:kayan_hr/constants.dart';
import 'employee_vacations.dart';
import 'package:kayan_hr/components/menu_button.dart';
import 'package:easy_localization/easy_localization.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const String id = 'homepage';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map> employeesVacations = [];

  void getAllEmployeesVacations() async {
    List<Map> employeesVacationsTemp = [];
    final employeesDocs = await EmployeeModel.getAllEmployees();
    employeesDocs.forEach((employee) async {
      employeesVacationsTemp.add({
        'emp_id': employee.id,
        'emp_name': employee['name'],
        'emp_created_at': employee['created_at'],
        'annual_count': await VacationModel.getNoOfDaysUsedInVacation(employee.id, 1),
        'casual_count': await VacationModel.getNoOfDaysUsedInVacation(employee.id, 2),
        'sick_count': await VacationModel.getNoOfDaysUsedInVacation(employee.id, 3),
        'grant_count': await VacationModel.getNoOfDaysUsedInVacation(employee.id, 4),
        'rotation_count': await VacationModel.getNoOfDaysUsedInVacation(employee.id, 5),
      });
      setState(() {
        employeesVacations = employeesVacationsTemp;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getAllEmployeesVacations();
  }

  @override
  Widget build(BuildContext context) {
    ///sorting
    if (employeesVacations.isNotEmpty) {
      //sort by employee created_at
      employeesVacations.sort((empVac1, empVac2) {
        return (empVac2['emp_created_at']).compareTo(empVac1['emp_created_at']);
      });
      //sort by employee rotation_count
      employeesVacations.sort((empVac1, empVac2) {
        return (empVac1['rotation_count']).compareTo(empVac2['rotation_count']);
      });
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr('home_title')),
        actions: [MenuButton()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (i) {
          switch (i) {
            case 0:
              Provider.of<CurrentUserRule>(context, listen: false).rule >= 3
                  ? Navigator.pushNamed(context, AddEmployee.id)
                  : Navigator.pushNamedAndRemoveUntil(context, EmployeeHomePage.id, (route) => false);
              break;
            case 1:
              Navigator.pushNamed(context, RegisterVacation.id);
              break;
          }
        },
        items: [
          Provider.of<CurrentUserRule>(context, listen: false).rule >= 3
              ? BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: tr('add_employee'),
                )
              : BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: tr('employee_home_title'),
                ),
          BottomNavigationBarItem(
            icon: Icon(Icons.weekend),
            label: tr('register_vacation'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('annual'), style: kHeaderTextStyle),
                Text(tr('casual'), style: kHeaderTextStyle),
                Text(tr('sick'), style: kHeaderTextStyle),
                Text(tr('grant'), style: kHeaderTextStyle),
                Flexible(child: Text(tr('rotation'), style: kHeaderTextStyle, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Divider(
            color: Colors.black,
            height: 0,
            thickness: 3,
          ),
          employeesVacations.isEmpty
              ? Expanded(child: loading())
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: RawScrollbar(
                      thumbColor: kMainColor,
                      thickness: 3,
                      child: ListView.builder(
                        itemCount: employeesVacations.length,
                        itemBuilder: (context, i) {
                          return Card(
                            color: Colors.grey.shade100,
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: ListTile(
                                onTap: () async {
                                  Navigator.pushNamed(
                                    context,
                                    EmployeeVacations.id,
                                    arguments: await EmployeeModel.getEmployeeById(employeesVacations[i]['emp_id']),
                                  );
                                },
                                title: Text(
                                  employeesVacations[i]['emp_name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.teal.shade600,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: context.locale.toString() == 'ar_DZ'
                                      ? EdgeInsets.only(right: 5, bottom: 5, top: 5)
                                      : EdgeInsets.only(left: 30, bottom: 5, top: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${employeesVacations[i]['annual_count']}'.toString(),
                                          style: kNumbersTextStyle),
                                      Text(employeesVacations[i]['casual_count'].toString(), style: kNumbersTextStyle),
                                      Text(employeesVacations[i]['sick_count'].toString(), style: kNumbersTextStyle),
                                      Text(employeesVacations[i]['grant_count'].toString(), style: kNumbersTextStyle),
                                      Flexible(
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Center(
                                            child: Text(employeesVacations[i]['rotation_count'].toString(),
                                                style: kNumbersTextStyle.copyWith(color: Colors.white, fontSize: 17)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
