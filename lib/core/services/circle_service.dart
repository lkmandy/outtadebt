import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:outtadebt/circles/models/circle.dart';

export 'package:outtadebt/circles/models/circle.dart';

class CircleService {
  final FirebaseFirestore _firestore;

  CircleService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> createCircle({
    required String name,
    required String description,
    required double goalAmount,
    required String creatorId,
    required CircleCategory category,
  }) async {
    final circle = Circle(
      id: '',
      name: name,
      description: description,
      goalAmount: goalAmount,
      currentAmount: 0.0,
      memberIds: [creatorId],
      creatorId: creatorId,
      createdAt: DateTime.now(),
      category: category,
    );
    final docRef =
        await _firestore.collection('circles').add(circle.toFirestore());
    return docRef.id;
  }

  Stream<List<Circle>> getCircles() {
    return _firestore
        .collection('circles')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Circle.fromFirestore(doc)).toList());
  }

  Stream<List<Circle>> getUserCircles(String userId) {
    return _firestore
        .collection('circles')
        .where('memberIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Circle.fromFirestore(doc)).toList());
  }

  Future<Circle?> getCircleById(String circleId) async {
    final doc = await _firestore.collection('circles').doc(circleId).get();
    if (!doc.exists) return null;
    return Circle.fromFirestore(doc);
  }

  Future<void> joinCircle({
    required String circleId,
    required String userId,
    required String displayName,
  }) async {
    await _firestore.collection('circles').doc(circleId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
    await _firestore
        .collection('circles')
        .doc(circleId)
        .collection('members')
        .doc(userId)
        .set(CircleMember(
          userId: userId,
          displayName: displayName,
          contribution: 0.0,
          joinedAt: DateTime.now(),
        ).toMap());
  }

  Future<void> leaveCircle({
    required String circleId,
    required String userId,
  }) async {
    await _firestore.collection('circles').doc(circleId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
    });
    await _firestore
        .collection('circles')
        .doc(circleId)
        .collection('members')
        .doc(userId)
        .delete();
  }

  Future<void> addContribution({
    required String circleId,
    required String userId,
    required double amount,
  }) async {
    final circleRef = _firestore.collection('circles').doc(circleId);
    await _firestore.runTransaction((transaction) async {
      final circleDoc = await transaction.get(circleRef);
      final circle = Circle.fromFirestore(circleDoc);
      transaction.update(
          circleRef, {'currentAmount': circle.currentAmount + amount});

      final memberRef = circleRef.collection('members').doc(userId);
      final memberDoc = await transaction.get(memberRef);
      if (memberDoc.exists) {
        final member = CircleMember.fromMap(
            memberDoc.data() as Map<String, dynamic>);
        transaction
            .update(memberRef, {'contribution': member.contribution + amount});
      }
    });
  }
}
