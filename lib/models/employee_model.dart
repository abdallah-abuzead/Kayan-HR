import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kayan_hr/models/user_model.dart';
import 'dart:io';

import 'package:kayan_hr/models/vacation_model.dart';

class EmployeeModel {
  static CollectionReference _employeeCollection = FirebaseFirestore.instance.collection('employee');

  static Future<List<QueryDocumentSnapshot>> getAllEmployees() async {
    final employees =
        await _employeeCollection.orderBy('created_at', descending: true).where('rule_id', whereIn: [1, 2]).get();
    return employees.docs;
  }

  static Future<QueryDocumentSnapshot> getEmployeeByEmail(String email) async {
    final employee = await _employeeCollection.where('email', isEqualTo: email).get();
    return employee.docs.first;
  }

  static Future<DocumentSnapshot> getEmployeeById(String empId) async {
    final employee = await _employeeCollection.doc(empId).get();
    return employee;
  }

  static Future addEmployee(Map<String, dynamic> employee) async {
    await _employeeCollection
        .add(employee)
        .then((value) => print('Employee added'))
        .catchError((error) => print('Failed to add the Employee: $error'));
  }

  static Future updateEmployee(String empId, Map<String, dynamic> updatedData) async {
    await _employeeCollection.doc(empId).update(updatedData).then((value) {
      print('Employee updated');
    });
  }

  static Future<String> storeEmployeeImage(String imageName, File file) async {
    String imageUrl = '';
    try {
      var imageStorageRef = FirebaseStorage.instance.ref('images/$imageName');
      await imageStorageRef.putFile(file);
      imageUrl = await imageStorageRef.getDownloadURL();
    } on FirebaseException catch (e) {
      print(e);
    }
    return imageUrl;
  }

  static Future<bool> isEmailExists(String email) async {
    final employees = await _employeeCollection.where('email', isEqualTo: email).get();
    return employees.docs.length > 0 ? true : false;
  }

  static Future deleteEmployeeImage(String imageUrl) async {
    FirebaseStorage.instance.refFromURL(imageUrl).delete().then((value) => print('image deleted'));
  }

  static Future deleteEmployee(String empId, String imageUrl) async {
    final employee = await _employeeCollection.doc(empId).get();
    await UserModel.deleteUser(employee['email']);
    _employeeCollection.doc(empId).delete().then((value) async {
      VacationModel.deleteAllEmployeeVacations(empId);
      if (imageUrl != '') await deleteEmployeeImage(imageUrl);
      print('employee deleted');
    });
  }
}
