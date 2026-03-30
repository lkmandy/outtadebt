import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum DebtType {
  creditCard,
  studentLoan,
  mortgage,
  carLoan,
  medicalBill,
  other;

  String get displayName {
    switch (this) {
      case DebtType.creditCard:
        return 'Credit Card';
      case DebtType.studentLoan:
        return 'Student Loan';
      case DebtType.mortgage:
        return 'Mortgage';
      case DebtType.carLoan:
        return 'Car Loan';
      case DebtType.medicalBill:
        return 'Medical Bill';
      case DebtType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case DebtType.creditCard:
        return Icons.credit_card;
      case DebtType.studentLoan:
        return Icons.school;
      case DebtType.mortgage:
        return Icons.home;
      case DebtType.carLoan:
        return Icons.directions_car;
      case DebtType.medicalBill:
        return Icons.local_hospital;
      case DebtType.other:
        return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case DebtType.creditCard:
        return const Color(0xFFEF4444); // red-500
      case DebtType.studentLoan:
        return const Color(0xFF3B82F6); // blue-500
      case DebtType.mortgage:
        return const Color(0xFF8B5CF6); // violet-500
      case DebtType.carLoan:
        return const Color(0xFFF59E0B); // amber-500
      case DebtType.medicalBill:
        return const Color(0xFFEC4899); // pink-500
      case DebtType.other:
        return const Color(0xFF6B7280); // gray-500
    }
  }
}

class Debt {
  final String id;
  final String userId;
  final String name;
  final DebtType type;
  final double balance;
  final double interestRate;
  final double minimumPayment;
  final int dueDay;
  final DateTime createdAt;

  Debt({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.interestRate,
    required this.minimumPayment,
    required this.dueDay,
    required this.createdAt,
  });

  factory Debt.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Debt(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      type: DebtType.values[data['type'] as int],
      balance: (data['balance'] as num).toDouble(),
      interestRate: (data['interestRate'] as num).toDouble(),
      minimumPayment: (data['minimumPayment'] as num).toDouble(),
      dueDay: data['dueDay'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'type': type.index,
      'balance': balance,
      'interestRate': interestRate,
      'minimumPayment': minimumPayment,
      'dueDay': dueDay,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Debt copyWith({
    String? id,
    String? userId,
    String? name,
    DebtType? type,
    double? balance,
    double? interestRate,
    double? minimumPayment,
    int? dueDay,
    DateTime? createdAt,
  }) {
    return Debt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      interestRate: interestRate ?? this.interestRate,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      dueDay: dueDay ?? this.dueDay,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
