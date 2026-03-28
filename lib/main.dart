import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'services/auth_service.dart';
import 'services/speech_service.dart';
import 'services/llm_service.dart';
import 'services/purchases_service.dart';
import 'services/notification_service.dart';
import 'features/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize services
  final purchasesService = PurchasesService();
  await purchasesService.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(AskBeeApp(
    purchasesService: purchasesService,
    notificationService: notificationService,
  ));
}

class AskBeeApp extends StatelessWidget {
  final PurchasesService purchasesService;
  final NotificationService notificationService;

  const AskBeeApp({
    super.key,
    required this.purchasesService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<SpeechService>(create: (_) => SpeechService()),
        Provider<LlmService>(create: (_) => LlmService()),
        Provider<PurchasesService>(create: (_) => purchasesService),
        Provider<NotificationService>(create: (_) => notificationService),
        StreamProvider(
          initialData: null,
          create: (context) => context.read<AuthService>().userStream,
        ),
      ],
      child: MaterialApp(
        title: 'AskBee',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}
