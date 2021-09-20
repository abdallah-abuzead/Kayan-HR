import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kayan_hr/models/employee_model.dart';

class UserModel {
  static CollectionReference _userCollection = FirebaseFirestore.instance.collection('user');
  static FirebaseAuth _auth = FirebaseAuth.instance;

  static String get currentUserEmail => _auth.currentUser?.email as String;

  static User? get currentUser => _auth.currentUser;

  static Future<List<QueryDocumentSnapshot>> getAllUsers() async {
    final users = await _userCollection
        .where('email', isNotEqualTo: 'super_admin@kayan.eg')
        // .orderBy('updated_at', descending: true)
        .get();
    return users.docs;
  }

  static Future<QueryDocumentSnapshot> getUserByEmail(String email) async {
    final users = await _userCollection.where('email', isEqualTo: email).get();
    return users.docs.first;
  }

  static Future addUser(Map<String, dynamic> user) async {
    await _userCollection
        .add(user)
        .then((value) => print('User added'))
        .catchError((error) => print('Failed to add the User: $error'));
  }

  static Future updateUser(String userId, Map<String, dynamic> user) async {
    await _userCollection
        .doc(userId)
        .update(user)
        .then((value) => print('User updated'))
        .catchError((error) => print('Failed to update the User: $error'));
  }

  static Future resetPassword(String currentPassword, String newPassword) async {
    AuthCredential credentials = EmailAuthProvider.credential(
      email: UserModel.currentUserEmail,
      password: currentPassword,
    );
    var result = await UserModel.currentUser?.reauthenticateWithCredential(credentials);
    result!.user?.updatePassword(newPassword);
  }

  static Future updateUserEmailOnFirebase(String oldEmail, String newEmail) async {
    final user = await UserModel.getUserByEmail(oldEmail);
    String password = user['password'];
    String currentUserEmail = UserModel.currentUserEmail;

    if (currentUserEmail == oldEmail) {
      // update my account email
      AuthCredential credentials = EmailAuthProvider.credential(email: oldEmail, password: password);
      UserCredential? userCredential = await UserModel.currentUser?.reauthenticateWithCredential(credentials);
      await userCredential!.user?.updateEmail(newEmail);
      await _auth.signInWithEmailAndPassword(email: newEmail, password: password);
    } else {
      // update user account email by admin
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: oldEmail, password: password);
      await userCredential.user?.updateEmail(newEmail);
      final currentUser = await UserModel.getUserByEmail(currentUserEmail);
      await _auth.signInWithEmailAndPassword(email: currentUserEmail, password: currentUser['password']);
    }
  }

  static Future deleteUser(String email) async {
    String adminEmail = UserModel.currentUserEmail;
    await _userCollection.where('email', isEqualTo: email).get().then((users) async {
      if (users.docs.isNotEmpty) {
        final user = users.docs.first;
        UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(email: email, password: user['password']);
        await userCredential.user?.delete();
        await _userCollection.doc(user.id).delete().then((value) => print('user deleted'));

        if (adminEmail != email) {
          // admin delete other users
          await _userCollection.where('email', isEqualTo: adminEmail).get().then((users) async {
            final user = users.docs.first;
            await _auth.signInWithEmailAndPassword(email: adminEmail, password: user['password']);
          });
        } else {
          // admin delete himself
          final employee = await EmployeeModel.getEmployeeByEmail(adminEmail);
          employee.reference.delete();
        }
      }
    });
  }

  static Future<bool> isEmailExist(String email) async {
    final users = await _userCollection.where('email', isEqualTo: email).get();
    return users.docs.length > 0 ? true : false;
  }

  static Future signOut() async {
    await _auth.signOut();
  }
}
