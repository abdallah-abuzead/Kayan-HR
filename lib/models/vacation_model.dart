import 'package:cloud_firestore/cloud_firestore.dart';

class VacationModel {
  static CollectionReference _vacationRequestCollection = FirebaseFirestore.instance.collection('vacation_request');
  static CollectionReference _vacationCollection = FirebaseFirestore.instance.collection('vacation');

  static Future<List<QueryDocumentSnapshot>> getEmployeeVacations(var empId, var vacId) async {
    final vacations = await _vacationRequestCollection
        .where('emp_id', isEqualTo: empId)
        .where('vac_id', isEqualTo: vacId)
        .where('status_id', isEqualTo: 2)
        .orderBy('created_at', descending: true)
        .get();
    return vacations.docs;
  }

  static Future<List<QueryDocumentSnapshot>> getAllNewVacationsRequests() async {
    final requests =
        await _vacationRequestCollection.where('status_id', isEqualTo: 1).orderBy('created_at', descending: true).get();
    return requests.docs;
  }

  static Future<List<QueryDocumentSnapshot>> getMyVacationsRequests(String id) async {
    final requests = await _vacationRequestCollection
        .where('emp_id', isEqualTo: id)
        .where('status_id', isEqualTo: 1)
        .orderBy('created_at', descending: true)
        .get();
    return requests.docs;
  }

  static void deleteAllEmployeeVacations(String empId) {
    _vacationRequestCollection.where('emp_id', isEqualTo: empId).get().then((vacs) {
      vacs.docs.forEach((vac) {
        vac.reference.delete();
      });
    });
  }

  static Future getVacationsTypes() async {
    final vacationsTypes = await _vacationCollection.orderBy('id').get();
    return vacationsTypes.docs;
  }

  static Future<QueryDocumentSnapshot> getVacation(int vacId) async {
    var vacation = await _vacationCollection.where('id', isEqualTo: vacId).get();
    return vacation.docs.first;
  }

  static Future addVacation(Map<String, dynamic> vacation) async {
    await _vacationRequestCollection.add(vacation).then((value) {
      print('vacation added');
    });
  }

  static Future<num> getNoOfDaysUsedInVacation(var empId, var vacId) async {
    num total = 0;
    await _vacationRequestCollection
        .where('emp_id', isEqualTo: empId)
        .where('vac_id', isEqualTo: vacId)
        .where('status_id', isEqualTo: 2)
        .get()
        .then((vacations) {
      if (vacations.docs.isNotEmpty) {
        vacations.docs.forEach((vacation) {
          total += (vacation.data() as Map)['no_of_days'];
        });
      }
    });
    return total;
  }

  static Future updateVacation(String docId, Map<String, dynamic> updatedData) async {
    _vacationRequestCollection.doc(docId).update(updatedData).then((value) => print('vacation edited'));
  }

  static Future deleteVacation(String docId) async {
    await _vacationRequestCollection.doc(docId).delete().then((value) => print('vacation deleted'));
  }
}
