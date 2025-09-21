import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

FirebaseFirestore get firestoreInstance => FirebaseFirestore.instanceFor(
  app: Firebase.app(),
);

class FirestoreService {
  final FirebaseFirestore _firestore = firestoreInstance;

  // Add a new showroom to Firestore
  Future<void> addShowroom(Map<String, dynamic> showroomData) async {
    try {
      await _firestore.collection('showrooms').add(showroomData);
    } catch (e) {
      throw Exception('Failed to add showroom: $e');
    }
  }

  // Get all showrooms
  Stream<QuerySnapshot> getShowrooms() {
    return _firestore.collection('showrooms').snapshots();
  }

  // Get a specific showroom by ID
  Future<DocumentSnapshot> getShowroom(String id) async {
    return await _firestore.collection('showrooms').doc(id).get();
  }

  // Update a showroom
  Future<void> updateShowroom(String id, Map<String, dynamic> updatedData) async {
    await _firestore.collection('showrooms').doc(id).update(updatedData);
  }

  // Delete a showroom
  Future<void> deleteShowroom(String id) async {
    await _firestore.collection('showrooms').doc(id).delete();
  }
}

class AppDb {
  static final FirebaseFirestore _db = firestoreInstance;

  // Lightweight activity logging helper
  static Future<void> logActivity({
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await _db.collection('activityLogs').add({
        'type': type,
        'payload': payload,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Non-fatal: swallow errors to avoid breaking UX
    }
  }
}