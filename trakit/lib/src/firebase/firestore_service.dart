import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trakit/client/models/goal.dart';
import 'package:trakit/client/models/week.dart';

class FirestoreService {
  FirestoreService._internal();

  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<String?> createGoal(Goal goal) async {
    try {
      final data = goal.toJson();

      if (currentUserId != null) {
        data['idUsuario'] = currentUserId;
      }

      final docRef = await _db.collection('goals').add(data);
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<List<Goal>> getGoals({String? userId}) async {
    try {
      final uid = userId ?? currentUserId;

      Query<Map<String, dynamic>> query = _db.collection('goals');

      if (uid != null) {
        query = query.where('idUsuario', isEqualTo: uid);
      }

      final snapshot = await query.get();

      final goals = snapshot.docs.map((doc) {
        final data = doc.data();

        return Goal.fromJson({'id': doc.id, ...data});
      }).toList();

      return goals;
    } catch (e) {
      return [];
    }
  }

  Stream<List<Goal>> goalsStream({String? userId}) {
    final uid = userId ?? currentUserId;

    Query<Map<String, dynamic>> query = _db.collection('goals');

    if (uid != null) {
      query = query.where('idUsuario', isEqualTo: uid);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Goal.fromJson({'id': doc.id, ...data});
      }).toList();
    });
  }

  Future<bool> deleteGoal(String goalId) async {
    try {
      await _db.collection('goals').doc(goalId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> createWeek(Week week) async {
    try {
      final data = week.toJson();

      final docRef = await _db.collection('weeks').add(data);
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<List<Week>> getWeeksByGoal(String goalId) async {
    try {
      final query = await _db
          .collection('weeks')
          .where('idObjetivo', isEqualTo: goalId)
          .get();

      final weeks = query.docs.map((doc) {
        final data = doc.data();

        return Week.fromJson({'id': doc.id, ...data});
      }).toList();

      return weeks;
    } catch (e) {
      return [];
    }
  }

  Stream<List<Week>> weeksStreamByGoal(String goalId) {
    final query = _db
        .collection('weeks')
        .where('idObjetivo', isEqualTo: goalId);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Week.fromJson({'id': doc.id, ...data});
      }).toList();
    });
  }

  Future<bool> deleteWeek(String weekId) async {
    try {
      await _db.collection('weeks').doc(weekId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
