class AppConstants {
  // LLM - Groq API (free tier)
  static const String groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String groqModel = 'llama-3.3-70b-versatile'; // Free tier model

  // Tiers
  static const int freeQuestionsPerWeek = 10;
  static const int premiumQuestionsPerMonth = 500;
  static const double premiumPrice = 9.99;

  // Content Filter Ages
  static const List<String> ageGroups = ['Kids (4+)', 'Teen (13+)', 'General', 'Mature'];
  static const String defaultAgeGroup = 'Kids (4+)';

  // Firestore Collections
  static const String usersCollection = 'users';
}
