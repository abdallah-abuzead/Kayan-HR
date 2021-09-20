import 'package:flutter/foundation.dart';

class SelectedEmployeesProvider extends ChangeNotifier {
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
