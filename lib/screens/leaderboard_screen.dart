import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:space_shooter_2400/screens/select_spaceship.dart';

import '../models/firebase.dart';
import 'create_account.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<QuerySnapshot> _futureScores;
  final FireBase fb = FireBase();
  final IDStorage idStorage = IDStorage();
  late String _username = "";

  @override
  void initState() {
    super.initState();
    idStorage.readID().then((String value) {
      fb.getNameByID(value).then((String username) {
        setState(() {
          _username = username;
        });
      });
    });
    _futureScores = fb.getTopScores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => SelectSpaceship(username: _username),
              ),
            );
          },
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _futureScores,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              final doc = snapshot.data!.docs[index];
              return ListTile(
                leading: Text('${index + 1}'), // No
                title: Text('${doc['name']}'), // Name
                trailing: Text('${doc['score']}'), // High Score
              );
            },
          );
        },
      ),
    );
  }
}
