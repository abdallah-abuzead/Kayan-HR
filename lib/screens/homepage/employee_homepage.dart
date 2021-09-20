import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kayan_hr/components/cookbooks/loading.dart';
import 'package:kayan_hr/components/providers/current_user_data_provider.dart';
import 'package:kayan_hr/components/navigation_list/side_drawer.dart';
import 'package:kayan_hr/constants.dart';
import 'package:badges/badges.dart';
import 'package:kayan_hr/models/employee_model.dart';
import 'package:kayan_hr/models/user_model.dart';
import 'package:kayan_hr/models/vacation_model.dart';
import 'package:kayan_hr/screens/vacations/employee_vacations.dart';
import 'package:kayan_hr/screens/homepage/homepage.dart';
import 'package:kayan_hr/screens/vacations/my_new_vacations_requests.dart';
import 'package:kayan_hr/screens/vacations/register_vacation.dart';
import 'package:provider/provider.dart';

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({Key? key}) : super(key: key);
  static const String id = 'employee_homepage';

  @override
  _EmployeeHomePageState createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  Map totalUsedVacations = {};
  int totalVacationsRequests = 0;
  var employee;
  void initUI() async {
    employee = await EmployeeModel.getEmployeeByEmail(UserModel.currentUserEmail);
    var requests = await VacationModel.getMyVacationsRequests(employee.id);
    var totalUsedVacationsTemp = {
      'annual_count': await VacationModel.getNoOfDaysUsedInVacation(employee.id, 1),
      'casual_count': await VacationModel.getNoOfDaysUsedInVacation(employee.id, 2),
      'sick_count': await VacationModel.getNoOfDaysUsedInVacation(employee.id, 3),
      'grant_count': await VacationModel.getNoOfDaysUsedInVacation(employee.id, 4),
      'rotation_count': await VacationModel.getNoOfDaysUsedInVacation(employee.id, 5),
    };
    setState(() {
      totalUsedVacations = totalUsedVacationsTemp;
      totalVacationsRequests = requests.length;
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
        title: Text(tr('employee_home_title')),
        // actions: [MenuButton()],
      ),
      drawer: SideDrawer(context),
      bottomNavigationBar: Provider.of<CurrentUserDataProvider>(context, listen: false).rule != 2
          ? null
          : BottomNavigationBar(
              onTap: (i) {
                switch (i) {
                  case 0:
                    Navigator.pushNamed(context, HomePage.id);
                    break;
                  case 1:
                    Navigator.pushNamed(context, RegisterVacation.id, arguments: employee);
                    break;
                }
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: tr('employees_vacations'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.weekend),
                  label: tr('create_vacation_request'),
                ),
              ],
            ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: totalUsedVacations.isEmpty
                ? loading()
                : ListView(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      SizedBox(height: 40),
                      TotalVacationDataContainer(
                        child: Column(
                          children: [
                            Text(tr('total_used_vacations'),
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 30),
                            TotalVacationsData(
                              vacationName: tr('annual'),
                              daysCount: totalUsedVacations['annual_count'],
                              vacationIcon:
                                  FaIcon(FontAwesomeIcons.umbrellaBeach, color: Colors.lightBlueAccent, size: 20),
                            ),
                            SizedBox(height: 20),
                            TotalVacationsData(
                              vacationName: tr('casual'),
                              daysCount: totalUsedVacations['casual_count'],
                              vacationIcon:
                                  FaIcon(FontAwesomeIcons.carCrash, color: Colors.redAccent.shade100, size: 20),
                            ),
                            SizedBox(height: 20),
                            TotalVacationsData(
                              vacationName: tr('sick'),
                              daysCount: totalUsedVacations['sick_count'],
                              vacationIcon: FaIcon(FontAwesomeIcons.procedures, color: Colors.blue.shade700, size: 20),
                            ),
                            SizedBox(height: 20),
                            TotalVacationsData(
                              vacationName: tr('grant'),
                              daysCount: totalUsedVacations['grant_count'],
                              vacationIcon: FaIcon(FontAwesomeIcons.gift, color: Colors.blueGrey, size: 20),
                            ),
                            SizedBox(height: 20),
                            TotalVacationsData(
                              vacationName: tr('Rotation'),
                              daysCount: totalUsedVacations['rotation_count'],
                              vacationIcon: FaIcon(FontAwesomeIcons.syncAlt, color: Colors.lightGreen, size: 20),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, EmployeeVacations.id, arguments: employee);
                        },
                      ),
                      SizedBox(height: 40),
                      TotalVacationDataContainer(
                        child: Column(
                          children: [
                            Text(tr('my_vacations_requests'),
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(tr('you_have'), style: TextStyle(fontSize: 16)),
                                Badge(
                                  badgeContent: Text(
                                    totalVacationsRequests.toString(),
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                  badgeColor: Colors.deepPurple,
                                  elevation: 2,
                                  padding: EdgeInsets.all(10),
                                ),
                                Text(tr('vacations_requests'), style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, MyNewVacationsRequests.id);
                        },
                      )
                    ],
                  ),
          ),
          Provider.of<CurrentUserDataProvider>(context, listen: false).rule == 2
              ? Container()
              : ElevatedButton(
                  child: Column(
                    children: [
                      Icon(Icons.weekend_rounded, size: 35),
                      Text(tr('create_vacation_request'), style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(10),
                    padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, RegisterVacation.id, arguments: employee);
                  },
                )
        ],
      ),
    );
  }
}

class TotalVacationDataContainer extends StatelessWidget {
  TotalVacationDataContainer({required this.child, required this.onTap});
  final Widget child;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        child: child,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

class TotalVacationsData extends StatelessWidget {
  TotalVacationsData({required this.vacationName, required this.daysCount, required this.vacationIcon});
  final String vacationName;
  final int daysCount;
  final FaIcon vacationIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: kVacationLabelsWidth,
              child: Text(vacationName, style: kVacationLabelsTextStyle),
            ),
            Text(kVacationLabelsPostfix, style: kVacationLabelsTextStyle),
            Text(
              daysCount.toString(),
              style: kVacationLabelsTextStyle.copyWith(color: Colors.teal),
            ),
          ],
        ),
        vacationIcon,
      ],
    );
  }
}
