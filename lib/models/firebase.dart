import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/create_account.dart';
import 'account.dart';

class FireBase {
  final db = FirebaseFirestore.instance.collection("account");
  final IDStorage idStorage = IDStorage();

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

  void updateScore(String id,int score) {
    final data={"score":score};
    db.doc(id).set(data,SetOptions(merge: true));
  }

 Future<QuerySnapshot> getTopScores() {
    return db.orderBy('score', descending: true)
        .limit(10)
        .get();
  }
}
