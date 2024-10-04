import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DocumentSnapshot> getUserData() async {
    final user = _auth.currentUser!;
    final userId = user.uid;

    return _firestore.collection('users').doc(userId).get();
  }

  Stream<DocumentSnapshot> getUserDataStream() {
    final user = _auth.currentUser!;
    final userId = user.uid;

    return _firestore.collection('users').doc(userId).snapshots();
  }
}