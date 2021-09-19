import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kayan_hr/components/connectivity_provider.dart';
import 'package:kayan_hr/components/current_user_data.dart';
import 'package:kayan_hr/screens/create_new_admin.dart';
import 'package:kayan_hr/screens/edit_my_account.dart';
import 'package:kayan_hr/screens/edit_user_rule.dart';
import 'package:kayan_hr/screens/employee_homepage.dart';
import 'package:kayan_hr/screens/login.dart';
import 'package:kayan_hr/screens/my_new_vacations_requests.dart';
import 'package:kayan_hr/screens/new_vacations_requests.dart';
import 'package:kayan_hr/screens/no_internet.dart';
import 'package:kayan_hr/screens/register_vacation.dart';
import 'package:kayan_hr/screens/reset_password.dart';
import 'package:kayan_hr/screens/sign_up.dart';
import 'package:kayan_hr/screens/users.dart';
import 'package:kayan_hr/screens/vacations_types.dart';
import 'package:kayan_hr/screens/welcome.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'screens/add_employee.dart';
import 'screens/edit_employee.dart';
import 'screens/edit_vacation.dart';
import 'screens/employee_vacations.dart';
import 'screens/employees.dart';
import 'screens/homepage.dart';

class MyApp extends StatefulWidget {
  MyApp({required this.isLogin, required this.rule});
  final bool isLogin;
  final num rule;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var localeLang;
  @override
  @override
  Widget build(BuildContext context) {
    setState(() {
      localeLang = context.locale;
    });
    final ThemeData theme = ThemeData();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConnectivityProvider>(create: (context) => ConnectivityProvider()),
        ChangeNotifierProvider<CurrentUserData>(create: (context) => CurrentUserData())
      ],
      builder: (context, child) {
        Provider.of<ConnectivityProvider>(context).startMonitoring();
        bool isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
        return MaterialApp(
          initialRoute: isOnline
              ? widget.isLogin
                  ? widget.rule >= 3
                      ? HomePage.id
                      : EmployeeHomePage.id
                  : Welcome.id
              : NoInternet.id,
          routes: {
            Welcome.id: (context) => Welcome(),
            SignUp.id: (context) => SignUp(),
            Login.id: (context) => Login(),
            HomePage.id: (context) => HomePage(),
            AddEmployee.id: (context) => AddEmployee(),
            RegisterVacation.id: (context) => RegisterVacation(),
            EmployeeVacations.id: (context) => EmployeeVacations(),
            EditVacation.id: (context) => EditVacation(),
            Employees.id: (context) => Employees(),
            VacationsTypes.id: (context) => VacationsTypes(),
            EditEmployee.id: (context) => EditEmployee(),
            Users.id: (context) => Users(),
            EditUserRule.id: (context) => EditUserRule(),
            EditMyAccount.id: (context) => EditMyAccount(),
            CreateNewAdmin.id: (context) => CreateNewAdmin(),
            ResetPassword.id: (context) => ResetPassword(),
            EmployeeHomePage.id: (context) => EmployeeHomePage(),
            NewVacationsRequests.id: (context) => NewVacationsRequests(),
            MyNewVacationsRequests.id: (context) => MyNewVacationsRequests(),
            NoInternet.id: (context) => NoInternet(),
          },
          theme: theme.copyWith(
            primaryColor: kMainColor,
            appBarTheme: AppBarTheme(
              color: kMainColor,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: kMainColor,
              elevation: 10,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white,
              selectedLabelStyle: TextStyle(fontSize: 14),
              unselectedLabelStyle: TextStyle(fontSize: 14),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                primary: kMainColor,
                padding: EdgeInsets.all(15),
              ),
            ),
            dialogTheme: DialogTheme(
              titleTextStyle: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: localeLang,
        );
      },
    );
  }
}
