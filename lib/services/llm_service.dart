import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class LlmService {
  // Note: In production, store API key securely (e.g., Firebase Config)
  // For this demo, using Groq's free tier
  String? _apiKey;

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  Future<String?> generateResponse(String prompt, {String ageGroup = 'Kids (4+)'}) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return '⚠️ API key not configured. Please add your Groq API key to use the AI assistant.';
    }

    // Build system prompt based on age group
    String systemPrompt = _buildSystemPrompt(ageGroup);

    try {
      final response = await http.post(
        Uri.parse(AppConstants.groqApiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': AppConstants.groqModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else if (response.statusCode == 429) {
        return '😓 I\'m taking a quick break! Please try again in a moment.';
      } else {
        print('LlmService error: ${response.statusCode} - ${response.body}');
        return '🤔 Hmm, something went wrong. Let\'s try again!';
      }
    } catch (e) {
      print('LlmService exception: $e');
      return '🌐 I\'m having trouble connecting. Please check your internet and try again!';
    }
  }

  String _buildSystemPrompt(String ageGroup) {
    String basePrompt = '''You are AskMe, a friendly and helpful AI learning companion. 
Your goal is to help children and learners of all ages understand the world around them.
Be warm, patient, encouraging, and use simple language.
Always be kind and supportive.
Never provide harmful, violent, or inappropriate content.
Make learning fun and exciting!''';

    switch (ageGroup) {
      case 'Kids (4+)':
        return basePrompt + '''
AGE GROUP: Kids (4+)
- Use very simple words and short sentences
- Keep answers very brief (2-3 sentences max)
- Use fun examples kids can relate to (animals, toys, family)
- Be extra careful and nurturing
- Use emojis occasionally to make it fun 😊''';
      
      case 'Teen (13+)':
        return basePrompt + '''
AGE GROUP: Teen (13+)
- Use clear, straightforward language
- Provide moderate detail (a paragraph or two)
- Relate topics to teen interests when possible
- Be supportive of their curiosity
- Can use more complex vocabulary''';
      
      case 'Mature':
        return basePrompt + '''
AGE GROUP: Mature
- Provide detailed, comprehensive answers
- Use technical language when appropriate
- Give examples and context
- Be thorough and informative''';
      
      default: // General
        return basePrompt + '''
AGE GROUP: General
- Use clear, accessible language
- Provide balanced detail
- Be informative but not overwhelming''';
    }
  }
}
