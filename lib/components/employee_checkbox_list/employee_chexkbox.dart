import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kayan_hr/components/providers/selected_employees_provider.dart';
import 'package:kayan_hr/constants.dart';
import 'package:provider/provider.dart';

class EmployeeCheckbox extends StatefulWidget {
  EmployeeCheckbox({required this.employee});
  final QueryDocumentSnapshot employee;

  @override
  _EmployeeCheckboxState createState() => _EmployeeCheckboxState();
}

class _EmployeeCheckboxState extends State<EmployeeCheckbox> {
  bool? isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectedEmployeesProvider>(
      builder: (context, selectedEmployees, child) {
        return CheckboxListTile(
          title: Text((widget.employee.data() as Map)['name']),
          value: isChecked,
          activeColor: kMainColor,
          onChanged: (value) {
            setState(() {
              isChecked = value;
              if (isChecked as bool)
                selectedEmployees.add(widget.employee.id);
              else
                selectedEmployees.remove(widget.employee.id);
            });
          },
        );
      },
    );
  }
}
