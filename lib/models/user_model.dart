import 'package:cloud_firestore/cloud_firestore.dart';

class AskMeUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String authProvider; // 'google' | 'apple' | 'anonymous'
  final String ageGroup;
  final bool isPremium;
  final int weeklyFreeQuestions;
  final int monthlyPremiumQuestions;
  final DateTime? weeklyResetDate;
  final DateTime? monthlyResetDate;
  final DateTime createdAt;

  AskMeUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.authProvider,
    required this.ageGroup,
    this.isPremium = false,
    this.weeklyFreeQuestions = 0,
    this.monthlyPremiumQuestions = 0,
    this.weeklyResetDate,
    this.monthlyResetDate,
    required this.createdAt,
  });

  factory AskMeUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AskMeUser(
      uid: doc.id,
      email: data['email'],
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      authProvider: data['authProvider'] ?? 'unknown',
      ageGroup: data['ageGroup'] ?? 'Kids (4+)',
      isPremium: data['isPremium'] ?? false,
      weeklyFreeQuestions: data['weeklyFreeQuestions'] ?? 0,
      monthlyPremiumQuestions: data['monthlyPremiumQuestions'] ?? 0,
      weeklyResetDate: data['weeklyResetDate'] != null
          ? (data['weeklyResetDate'] as Timestamp).toDate()
          : null,
      monthlyResetDate: data['monthlyResetDate'] != null
          ? (data['monthlyResetDate'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'authProvider': authProvider,
      'ageGroup': ageGroup,
      'isPremium': isPremium,
      'weeklyFreeQuestions': weeklyFreeQuestions,
      'monthlyPremiumQuestions': monthlyPremiumQuestions,
      'weeklyResetDate': weeklyResetDate,
      'monthlyResetDate': monthlyResetDate,
      'createdAt': createdAt,
    };
  }

  AskMeUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? authProvider,
    String? ageGroup,
    bool? isPremium,
    int? weeklyFreeQuestions,
    int? monthlyPremiumQuestions,
    DateTime? weeklyResetDate,
    DateTime? monthlyResetDate,
    DateTime? createdAt,
  }) {
    return AskMeUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      authProvider: authProvider ?? this.authProvider,
      ageGroup: ageGroup ?? this.ageGroup,
      isPremium: isPremium ?? this.isPremium,
      weeklyFreeQuestions: weeklyFreeQuestions ?? this.weeklyFreeQuestions,
      monthlyPremiumQuestions: monthlyPremiumQuestions ?? this.monthlyPremiumQuestions,
      weeklyResetDate: weeklyResetDate ?? this.weeklyResetDate,
      monthlyResetDate: monthlyResetDate ?? this.monthlyResetDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
