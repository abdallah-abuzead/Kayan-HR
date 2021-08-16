import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kayan_hr/components/employee_chexkbox.dart';

class EmployeesCheckboxList extends StatelessWidget {
  EmployeesCheckboxList({required this.employees});
  final List<QueryDocumentSnapshot> employees;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, i) {
          return EmployeeCheckbox(employee: employees[i]);
        },
      ),
    );
  }
}
