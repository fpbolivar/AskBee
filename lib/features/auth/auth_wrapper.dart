import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../chat/home_screen.dart';
import '../auth/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AskBeeUser?>();
    
    if (user == null) {
      return const LoginScreen();
    }
    
    return const HomeScreen();
  }
}
