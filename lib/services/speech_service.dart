import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String? _lastRecognized;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    _isInitialized = await _speechToText.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );

    // Configure TTS
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5); // Slightly slower for kids
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.1); // Slightly higher pitch for friendly feel

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    return _isInitialized;
  }

  Future<String?> listenForSpeech() async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) return null;
    }

    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
      return _lastRecognized;
    }

    _lastRecognized = null;
    _isListening = true;

    // Listen for speech
    await _speechToText.listen(
      onResult: (result) {
        // Handle the recognized text
        // In speech_to_text 7.x, recognizedWords contains the text
        _lastRecognized = result.recognizedWords;
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
    );

    // Wait for user to stop speaking
    await Future.delayed(const Duration(seconds: 8));
    
    await _speechToText.stop();
    _isListening = false;
    
    return _lastRecognized;
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  Future<void> speak(String text) async {
    if (_isSpeaking) {
      await stopSpeaking();
    }

    _isSpeaking = true;
    await _flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
    }
  }

  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
  }

  // Check if device supports speech recognition
  Future<bool> get hasSpeechRecognition async {
    if (!_isInitialized) await initialize();
    return _isInitialized;
  }
}
