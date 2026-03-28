import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatStorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveMessage({
    required String uid,
    required String chatId,
    required ChatMessage message,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'text': message.text,
          'role': message.role.name,
          'createdAt': message.timestamp,
          'isSpeaking': message.isSpeaking,
        });
  }

  Future<List<ChatMessage>> loadMessages({
    required String uid,
    required String chatId,
    int limit = 100,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ChatMessage(
        id: doc.id,
        text: data['text'] ?? '',
        role: data['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
        timestamp: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isSpeaking: data['isSpeaking'] ?? false,
      );
    }).toList().reversed.toList();
  }

  Future<void> deleteOldMessages({
    required String uid,
    required String chatId,
    int keepLast = 100,
  }) async {
    final messagesRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(chatId)
        .collection('messages');

    final count = await messagesRef.count().get();
    final totalCount = count.count ?? 0;
    if (totalCount <= keepLast) return;

    final oldMessages = await messagesRef
        .orderBy('createdAt', descending: false)
        .limit(totalCount - keepLast)
        .get();

    for (final doc in oldMessages.docs) {
      await doc.reference.delete();
    }
  }

  Future<List<String>> getUserChatIds(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> deleteChat({required String uid, required String chatId}) async {
    // Delete all messages in the chat
    final messages = await _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    for (final doc in messages.docs) {
      await doc.reference.delete();
    }

    // Delete the chat document itself
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(chatId)
        .delete();
  }
}
