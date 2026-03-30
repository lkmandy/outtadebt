import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CircleMember {
  final String userId;
  final String displayName;
  final double contribution;
  final DateTime joinedAt;

  CircleMember({
    required this.userId,
    required this.displayName,
    required this.contribution,
    required this.joinedAt,
  });

  factory CircleMember.fromMap(Map<String, dynamic> data) {
    return CircleMember(
      userId: data['userId'] as String,
      displayName: data['displayName'] as String,
      contribution: (data['contribution'] as num).toDouble(),
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'contribution': contribution,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }
}

enum CircleCategory {
  creditCard,
  studentLoan,
  mortgage,
  carLoan,
  general;

  String get displayName {
    switch (this) {
      case CircleCategory.creditCard:
        return 'Credit Card';
      case CircleCategory.studentLoan:
        return 'Student Loan';
      case CircleCategory.mortgage:
        return 'Mortgage';
      case CircleCategory.carLoan:
        return 'Car Loan';
      case CircleCategory.general:
        return 'General';
    }
  }

  IconData get icon {
    switch (this) {
      case CircleCategory.creditCard:
        return Icons.credit_card;
      case CircleCategory.studentLoan:
        return Icons.school;
      case CircleCategory.mortgage:
        return Icons.home;
      case CircleCategory.carLoan:
        return Icons.directions_car;
      case CircleCategory.general:
        return Icons.people;
    }
  }

  Color get color {
    switch (this) {
      case CircleCategory.creditCard:
        return const Color(0xFFEF4444); // red-500
      case CircleCategory.studentLoan:
        return const Color(0xFF3B82F6); // blue-500
      case CircleCategory.mortgage:
        return const Color(0xFF8B5CF6); // violet-500
      case CircleCategory.carLoan:
        return const Color(0xFFF59E0B); // amber-500
      case CircleCategory.general:
        return const Color(0xFF10B981); // emerald-500
    }
  }
}

class Circle {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final double goalAmount;
  final double currentAmount;
  final List<String> memberIds;
  final CircleCategory category;
  final DateTime createdAt;

  Circle({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.goalAmount,
    required this.currentAmount,
    required this.memberIds,
    required this.category,
    required this.createdAt,
  });

  double get progressPercent => goalAmount > 0 ? (currentAmount / goalAmount) * 100 : 0;
  int get memberCount => memberIds.length;

  factory Circle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Circle(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String,
      creatorId: data['creatorId'] as String,
      goalAmount: (data['goalAmount'] as num).toDouble(),
      currentAmount: (data['currentAmount'] as num).toDouble(),
      memberIds: List<String>.from(data['memberIds'] as List),
      category: CircleCategory.values[data['category'] as int],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'goalAmount': goalAmount,
      'currentAmount': currentAmount,
      'memberIds': memberIds,
      'category': category.index,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Circle copyWith({
    String? id,
    String? name,
    String? description,
    String? creatorId,
    double? goalAmount,
    double? currentAmount,
    List<String>? memberIds,
    CircleCategory? category,
    DateTime? createdAt,
  }) {
    return Circle(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      goalAmount: goalAmount ?? this.goalAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      memberIds: memberIds ?? this.memberIds,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
