import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<AskBeeUser?> get userStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getOrCreateUser(firebaseUser);
    });
  }

  Future<AskBeeUser?> get currentUser async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return await _getOrCreateUser(firebaseUser);
  }

  Future<AskBeeUser> _getOrCreateUser(User firebaseUser) async {
    final docRef = _firestore.collection(AppConstants.usersCollection).doc(firebaseUser.uid);
    final doc = await docRef.get();

    if (doc.exists) {
      return AskBeeUser.fromFirestore(doc);
    }

    // Create new user
    final newUser = AskBeeUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      authProvider: _getProvider(firebaseUser),
      ageGroup: AppConstants.defaultAgeGroup,
      createdAt: DateTime.now(),
      weeklyResetDate: _getNextWeekReset(),
      monthlyResetDate: _getNextMonthReset(),
    );

    await docRef.set(newUser.toFirestore());
    return newUser;
  }

  String _getProvider(User user) {
    if (user.providerData.any((p) => p.providerId == 'google.com')) {
      return 'google';
    } else if (user.providerData.any((p) => p.providerId == 'apple.com')) {
      return 'apple';
    }
    return 'email';
  }

  DateTime _getNextWeekReset() {
    final now = DateTime.now();
    return now.add(Duration(days: 7 - now.weekday));
  }

  DateTime _getNextMonthReset() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 1);
  }

  Future<AskBeeUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return await _getOrCreateUser(userCredential.user!);
    } catch (e) {
      print('Google sign in error: $e');
      return null;
    }
  }

  Future<AskBeeUser?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(oauthCredential);
      return await _getOrCreateUser(userCredential.user!);
    } catch (e) {
      print('Apple sign in error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> updateUserAgeGroup(String uid, String ageGroup) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'ageGroup': ageGroup,
    });
  }

  Future<void> incrementQuestionCount(String uid, {bool isPremium = false}) async {
    final docRef = _firestore.collection(AppConstants.usersCollection).doc(uid);
    
    if (isPremium) {
      await docRef.update({
        'monthlyPremiumQuestions': FieldValue.increment(1),
      });
    } else {
      await docRef.update({
        'weeklyFreeQuestions': FieldValue.increment(1),
      });
    }
  }

  Future<bool> canAskQuestion(AskBeeUser user) async {
    if (user.isPremium) {
      // Check if monthly limit reached
      _resetMonthlyIfNeeded(user);
      return user.monthlyPremiumQuestions < AppConstants.premiumQuestionsPerMonth;
    } else {
      // Check if weekly limit reached
      _resetWeeklyIfNeeded(user);
      return user.weeklyFreeQuestions < AppConstants.freeQuestionsPerWeek;
    }
  }

  void _resetWeeklyIfNeeded(AskBeeUser user) {
    if (user.weeklyResetDate != null && DateTime.now().isAfter(user.weeklyResetDate!)) {
      // Week has reset - update Firestore
      _firestore.collection(AppConstants.usersCollection).doc(user.uid).update({
        'weeklyFreeQuestions': 0,
        'weeklyResetDate': _getNextWeekReset(),
      });
    }
  }

  void _resetMonthlyIfNeeded(AskBeeUser user) {
    if (user.monthlyResetDate != null && DateTime.now().isAfter(user.monthlyResetDate!)) {
      _firestore.collection(AppConstants.usersCollection).doc(user.uid).update({
        'monthlyPremiumQuestions': 0,
        'monthlyResetDate': _getNextMonthReset(),
      });
    }
  }

  Future<void> setPremiumStatus(String uid, bool isPremium) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'isPremium': isPremium,
    });
  }
}
