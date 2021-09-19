import 'package:cloud_firestore/cloud_firestore.dart';

class RuleModel {
  static CollectionReference _ruleCollection = FirebaseFirestore.instance.collection('rule');

  static Future<List<QueryDocumentSnapshot>> getAllRules() async {
    final rules = await _ruleCollection.where('id', whereIn: [1, 2]).get();
    return rules.docs;
  }

  static Future<String> getRuleName(num ruleId) async {
    final rule = await _ruleCollection.where('id', isEqualTo: ruleId).get();
    return rule.docs.first['rule'];
  }
}
