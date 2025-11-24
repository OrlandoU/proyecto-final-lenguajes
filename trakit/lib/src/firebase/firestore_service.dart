import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trakit/client/models/goal.dart';
import 'package:trakit/client/models/week.dart';
import 'package:trakit/client/models/user.dart';


class FirestoreService {
  FirestoreService._internal();

  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<String?> createGoal(Goal goal, double amount) async {
    try {
      final data = goal.toJson();

      if (currentUserId != null) {
        data['idUsuario'] = currentUserId;
      }    

      final docRef = await _db.collection('goals').add(data);
      for(int i= 0; i < 52;i++){
        final week = Week(
          completedStatus: false,
          realAmount: 0,
          plannedAmount: goal.goalType == 'fijo'? amount: amount * (i + 1),
          goalId: docRef.id,
          number : i + 1
        );
        await _db.collection('weeks').add(week.toJson());
      }
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

    Future<List<Week>> getWeeks({String? userId}) async {
    try {
      final uid = userId ?? currentUserId;

      Query<Map<String, dynamic>> query = _db.collection('weeks');

      if (uid != null) {
        query = query.where('idUsuario', isEqualTo: uid);
      }

      final snapshot = await query.get();

      final goals = snapshot.docs.map((doc) {
        final data = doc.data();

        return Week.fromJson({'id': doc.id, ...data});
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
    // 1️⃣ Borrar el goal
    await _db.collection('goals').doc(goalId).delete();

    // 2️⃣ Obtener todas las semanas relacionadas
    final weeksSnapshot = await _db
        .collection('weeks')
        .where('idObjetivo', isEqualTo: goalId)
        .get();

    // 3️⃣ Borrar todas las semanas
    final batch = _db.batch();
    for (var doc in weeksSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    return true;
  } catch (e) {
    print("Error deleting goal and its weeks: $e");
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
        .where('idObjetivo', isEqualTo: goalId).orderBy('numero');

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

  Future<Week?> getWeekById(String weekId) async {
    try {
      final doc = await _db.collection('weeks').doc(weekId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;

      return Week.fromJson({'id': doc.id, ...data});
    } catch (e) {
      return null;
    }
  }

Future<Week?> updateWeek(String weekId, Map<String, dynamic> data) async {
  try {
    // 1️⃣ Update the document
    await _db.collection('weeks').doc(weekId).update(data);

    // 2️⃣ Fetch the updated document
    final doc = await _db.collection('weeks').doc(weekId).get();

    if (!doc.exists) return null;

    final updatedData = doc.data()!;

    // 3️⃣ Return as Week object
    return Week.fromJson({'id': doc.id, ...updatedData});
  } catch (e) {
    print("Error updating week: $e");
    return null;
  }
}

}

