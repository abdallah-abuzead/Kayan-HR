import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kayan_hr/components/current_user_data.dart';
import 'package:kayan_hr/constants.dart';
import 'package:kayan_hr/screens/employee_homepage.dart';
import 'package:provider/provider.dart';
import 'vacations.dart';
import 'register_vacation.dart';
import 'package:kayan_hr/screens/homepage.dart';
import 'package:easy_localization/easy_localization.dart';

class EmployeeVacations extends StatefulWidget {
  const EmployeeVacations({Key? key}) : super(key: key);
  static String id = 'employee_vacations';

  @override
  _EmployeeVacationsState createState() => _EmployeeVacationsState();
}

class _EmployeeVacationsState extends State<EmployeeVacations> {
  @override
  Widget build(BuildContext context) {
    final employee = ModalRoute.of(context)!.settings.arguments as DocumentSnapshot;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            alignment: Alignment.center,
            margin: context.locale.toString() == 'ar_DZ' ? EdgeInsets.only(left: 20) : EdgeInsets.only(right: 20),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            color: Colors.white,
            child: Text(
              employee['name'],
              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          bottom: TabBar(
            labelPadding: EdgeInsets.only(bottom: 5),
            indicatorWeight: 3,
            tabs: [
              Text(tr('annual'), style: kTabsTextStyle),
              Text(tr('casual'), style: kTabsTextStyle),
              Text(tr('sick'), style: kTabsTextStyle),
              Text(tr('grant'), style: kTabsTextStyle),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                      child: Text(
                    tr('rotation'),
                    style: kTabsTextStyle,
                    overflow: TextOverflow.ellipsis,
                  )),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (i) {
            switch (i) {
              case 0:
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Provider.of<CurrentUserData>(context, listen: false).rule >= 3 ? HomePage.id : EmployeeHomePage.id,
                  (route) => false,
                );
                break;
              case 1:
                Navigator.pushNamed(
                  context,
                  RegisterVacation.id,
                  arguments: employee,
                );
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: tr('homepage'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.weekend),
              label: tr('register_vacation'),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            Tab(child: Vacations(empId: employee.id, vacId: 1)),
            Tab(child: Vacations(empId: employee.id, vacId: 2)),
            Tab(child: Vacations(empId: employee.id, vacId: 3)),
            Tab(child: Vacations(empId: employee.id, vacId: 4)),
            Tab(child: Vacations(empId: employee.id, vacId: 5)),
          ],
        ),
      ),
    );
  }
}
