import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'services/auth_service.dart';
import 'services/speech_service.dart';
import 'services/llm_service.dart';
import 'features/auth/auth_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AskMeApp());
}

class AskMeApp extends StatelessWidget {
  const AskMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<SpeechService>(create: (_) => SpeechService()),
        Provider<LlmService>(create: (_) => LlmService()),
        StreamProvider(
          initialData: null,
          create: (context) => context.read<AuthService>().userStream,
        ),
      ],
      child: MaterialApp(
        title: 'AskMe',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}
