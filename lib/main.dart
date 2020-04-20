import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(FlashChat());

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        textTheme: TextTheme(
          body1: TextStyle(color: Colors.black54),
        ),
      ),
      routes: {
        '/welcome': (_) => WelcomeScreen(),
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegistrationScreen(),
        '/chat': (_) => ChatScreen()
      },
      initialRoute: '/welcome',
    );
  }
}
