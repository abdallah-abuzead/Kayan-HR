import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:kayan_hr/models/employee_model.dart';
import 'package:kayan_hr/models/rule_model.dart';
import 'package:kayan_hr/models/user_model.dart';

class CurrentUserDataProvider extends ChangeNotifier {
  num rule = 1;
  Map currentUser = {};

  CurrentUserDataProvider() {
    initRule();
  }

  void initRule() async {
    if (UserModel.currentUser != null) {
      final employee = await EmployeeModel.getEmployeeByEmail(UserModel.currentUserEmail);
      final user = await UserModel.getUserByEmail(UserModel.currentUserEmail);
      rule = employee['rule_id'];
      currentUser = {
        'name': user['name'],
        'email': user['email'],
        'phone': user['phone'],
        'image_url': employee['image_url'],
        'rule_name': await RuleModel.getRuleName(employee['rule_id'])
      };
    }
  }

  void setCurrentUserData() async {
    final employee = await EmployeeModel.getEmployeeByEmail(UserModel.currentUserEmail);
    final user = await UserModel.getUserByEmail(UserModel.currentUserEmail);
    rule = employee['rule_id'];
    currentUser = {
      'name': user['name'],
      'email': user['email'],
      'phone': user['phone'],
      'image_url': employee['image_url'],
      'rule_name': await RuleModel.getRuleName(employee['rule_id'])
    };
    notifyListeners();
  }
}
