import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:outtadebt/home/models/debt.dart';

export 'package:outtadebt/home/models/debt.dart';

class DebtService {
  final FirebaseFirestore _firestore;

  DebtService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> addDebt({
    required String userId,
    required String name,
    required DebtType type,
    required double balance,
    required double interestRate,
    required double minimumPayment,
    required int dueDay,
  }) async {
    final debt = Debt(
      id: '',
      userId: userId,
      name: name,
      type: type,
      balance: balance,
      interestRate: interestRate,
      minimumPayment: minimumPayment,
      dueDay: dueDay,
      createdAt: DateTime.now(),
    );
    final docRef = await _firestore.collection('debts').add(debt.toFirestore());
    return docRef.id;
  }

  Stream<List<Debt>> getDebts(String userId) {
    return _firestore
        .collection('debts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Debt.fromFirestore(doc)).toList());
  }

  Future<void> updateDebt({
    required String debtId,
    String? name,
    DebtType? type,
    double? balance,
    double? interestRate,
    double? minimumPayment,
    int? dueDay,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (type != null) updates['type'] = type.index;
    if (balance != null) updates['balance'] = balance;
    if (interestRate != null) updates['interestRate'] = interestRate;
    if (minimumPayment != null) updates['minimumPayment'] = minimumPayment;
    if (dueDay != null) updates['dueDay'] = dueDay;
    await _firestore.collection('debts').doc(debtId).update(updates);
  }

  Future<void> deleteDebt(String debtId) async {
    await _firestore.collection('debts').doc(debtId).delete();
  }

  Stream<double> getTotalDebt(String userId) {
    return getDebts(userId).map((debts) =>
        debts.fold<double>(0.0, (total, debt) => total + debt.balance));
  }
}
