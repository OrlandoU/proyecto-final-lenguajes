import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trakit/client/models/user.dart';

Future<UserCredential?> signInWithGoogle() async {
  // Trigger the authentication flow
  try {
    final GoogleSignIn signIn = GoogleSignIn.instance;

    await signIn.initialize();

    // Obtain the auth details from the request
    final GoogleSignInAccount googleAuth = await signIn.authenticate();

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.authentication.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    print(e);
  }
}



void createUser() async {
  final firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser == null) return;

  final currentUserId = firebaseUser.uid;

  // Check if user already exists
  final userQuery = await FirebaseFirestore.instance
      .collection('users')
      .where('id', isEqualTo: currentUserId)
      .get();

  if (userQuery.docs.isEmpty) {
    // User does not exist, create a new one
    final newUser = UserE(
      id: firebaseUser.uid,
      dateCreated: DateTime.now(),
      displayName: firebaseUser.displayName ?? 'No Name',
      email: firebaseUser.email ?? 'No Email',
    );

    // Save to Firestore
    await FirebaseFirestore.instance.collection('users').doc(currentUserId).set(newUser.toJson());
  } else {}
}

Future<void> signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut(); // cierra la sesión

  if (!context.mounted) return;

  context.replace('/login');
}
