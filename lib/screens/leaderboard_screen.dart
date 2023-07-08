import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<QuerySnapshot> _futureScores;

  @override
  void initState() {
    super.initState();
    _futureScores = getTopScores();
  }

  Future<QuerySnapshot> getTopScores() {
    return FirebaseFirestore.instance
        .collection('scores')
        .orderBy('score', descending: true)
        .limit(10)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _futureScores,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              final doc = snapshot.data!.docs[index];
              return ListTile(
                leading: Text('${index + 1}'), // No
                title: Text('${doc['userId']}'), // Name
                trailing: Text('${doc['score']}'), // High Score
              );
            },
          );
        },
      ),
    );
  }
}
