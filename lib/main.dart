import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:kayan_hr/models/user_model.dart';
import 'app.dart';
import 'models/employee_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

FirebaseMessaging fcm = FirebaseMessaging.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  var user = UserModel.currentUser;
  bool isLogin = user != null;
  num rule = 0;
  if (isLogin) {
    final employee = await EmployeeModel.getEmployeeByEmail(UserModel.currentUserEmail);
    rule = employee['rule_id'];

    //============= notifications ==================
    // print('===================');
    // fcm.getToken().then((value) => print(value));
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   if (message.notification != null) {
    //     print(message.notification!.title);
    //   }
    // });
    //===============================================
  }
  runApp(
    Phoenix(
      child: EasyLocalization(
        supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
        path: 'assets/translations',
        startLocale: Locale('en', 'US'),
        fallbackLocale: Locale('en', 'US'),
        child: MyApp(isLogin: isLogin, rule: rule),
      ),
    ),
  );
}
