import 'package:flutter/foundation.dart';

class SelectedEmployeesData extends ChangeNotifier {
  List<String> selectedEmployeesIds = [];

  void add(String id) {
    selectedEmployeesIds.add(id);
    notifyListeners();
  }

  void remove(String id) {
    selectedEmployeesIds.remove(id);
    notifyListeners();
  }
}
