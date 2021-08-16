import 'package:flutter/foundation.dart';
import 'package:kayan_hr/models/employee_model.dart';
import 'package:kayan_hr/models/user_model.dart';

class CurrentUserRule extends ChangeNotifier {
  num rule = 1;

  CurrentUserRule() {
    initRule();
  }

  initRule() async {
    if (UserModel.currentUser != null) {
      final employee = await EmployeeModel.getEmployeeByEmail(UserModel.currentUserEmail);
      rule = employee['rule_id'];
    }
  }

  void set(num newRule) {
    rule = newRule;
    notifyListeners();
  }
}
