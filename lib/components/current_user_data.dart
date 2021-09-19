import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:kayan_hr/models/employee_model.dart';
import 'package:kayan_hr/models/rule_model.dart';
import 'package:kayan_hr/models/user_model.dart';

class CurrentUserData extends ChangeNotifier {
  num rule = 1;
  Map currentUser = {};

  CurrentUserData() {
    initRule();
  }

  void initRule() async {
    if (UserModel.currentUser != null) {
      final employee = await EmployeeModel.getEmployeeByEmail(UserModel.currentUserEmail);
      final user = await UserModel.getUserByEmail(UserModel.currentUserEmail);
      currentUser = {
        'name': user['name'],
        'email': user['email'],
        'phone': user['phone'],
        'image_url': employee['image_url'],
        'rule_name': await RuleModel.getRuleName(employee['rule_id'])
      };
      rule = employee['rule_id'];
    }
  }

  void setRule(num newRule) {
    rule = newRule;
    notifyListeners();
  }
}
