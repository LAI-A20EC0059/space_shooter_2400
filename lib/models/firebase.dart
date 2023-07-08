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
    late var user;
    await db.doc(id).get().then((value){
      user=value.data();
    });
    return user["name"];
  }

  void updateScore(int score) {
    //db.doc("get local id").set(score);
  }

 Future<QuerySnapshot> getTopScores() {
    return db.orderBy('score', descending: true)
        .limit(10)
        .get();
  }
}
