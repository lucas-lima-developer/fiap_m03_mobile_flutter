import 'package:fiap_m03_mobile_flutter/providers/transaction_provider.dart';
import 'package:fiap_m03_mobile_flutter/screens/home_screen.dart';
import 'package:fiap_m03_mobile_flutter/screens/transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart'; // Importe a tela de cadastro

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicia Firebase

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Rota inicial
      routes: {
        '/login': (context) => const LoginScreen(), // Rota para a tela de login
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/transaction': (context) =>
            const TransactionScreen() // Rota para a tela de cadastro
      },
    );
  }
}
