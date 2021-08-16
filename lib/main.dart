import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kayan_hr/components/current_user_rule_data.dart';
import 'package:kayan_hr/models/user_model.dart';
import 'package:kayan_hr/screens/create_new_admin.dart';
import 'package:kayan_hr/screens/edit_my_account.dart';
import 'package:kayan_hr/screens/edit_user_rule.dart';
import 'package:kayan_hr/screens/employee_homepage.dart';
import 'package:kayan_hr/screens/login.dart';
import 'package:kayan_hr/screens/my_new_vacations_requests.dart';
import 'package:kayan_hr/screens/new_vacations_requests.dart';
import 'package:kayan_hr/screens/reset_password.dart';
import 'package:kayan_hr/screens/sign_up.dart';
import 'package:kayan_hr/screens/users.dart';
import 'package:kayan_hr/screens/welcome.dart';
import 'package:provider/provider.dart';
import 'models/employee_model.dart';
import 'screens/homepage.dart';
import 'screens/add_employee.dart';
import 'screens/register_vacation.dart';
import 'constants.dart';
import 'screens/employee_vacations.dart';
import 'screens/edit_vacation.dart';
import 'screens/employees.dart';
import 'screens/vacations_types.dart';
import 'screens/edit_employee.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

bool isLogin = false;
num rule = 0;
FirebaseMessaging fcm = FirebaseMessaging.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  var user = UserModel.currentUser;
  isLogin = user == null ? false : true;
  if (isLogin) {
    final employee = await EmployeeModel.getEmployeeByEmail(UserModel.currentUserEmail);
    rule = employee['rule_id'];
    print('===================');
    fcm.getToken().then((value) => print(value));
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print(message.notification!.title);
      }
    });
  }
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
      path: 'assets/translations',
      startLocale: Locale('en', 'US'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CurrentUserRule>(
      create: (context) => CurrentUserRule(),
      builder: (context, child) {
        return MaterialApp(
          initialRoute: isLogin
              ? rule >= 3
                  ? HomePage.id
                  : EmployeeHomePage.id
              : Welcome.id,
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
          },
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(
            primaryColor: kMainColor,
            accentColor: kMainColor,
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
        );
      },
    );
  }
}
