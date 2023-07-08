import 'package:cloud_firestore/cloud_firestore.dart';

import 'account.dart';

class FireBase {
  final db = FirebaseFirestore.instance.collection("account");

  void addAccountByName(String name) {
    Account acc = Account();
    acc.name = name;
    db.add(acc.toMap());
  }

  Future<String> getIDByName(String name) async {
    late final String id;
    await db.where("name", isEqualTo: name).get().then((value) {
      id = value.docs[0].id;
    });
    return id;
  }

  Future<String> getNameByID(String id) async {
    late var value;
    var docSnapshot = await db.doc('doc_id').get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      value = data?['name']; // <-- The value you want to retrieve.

    }
    return value;
  }

  void updateScore(int score) {
    //db.doc("get local id").set(score);
  }

  //void getAccountByID(Account acc){
  //  db.doc(Account.)
  //}
}
