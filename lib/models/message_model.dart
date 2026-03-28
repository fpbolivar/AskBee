enum MessageRole { user, assistant }

class ChatMessage {
  final String id;
  final String text;
  final MessageRole role;
  final DateTime timestamp;
  final bool isSpeaking; // for TTS animation

  ChatMessage({
    required this.id,
    required this.text,
    required this.role,
    required this.timestamp,
    this.isSpeaking = false,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    MessageRole? role,
    DateTime? timestamp,
    bool? isSpeaking,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}
