import 'package:artisanhub11/pages/about_us_screen.dart';
import 'package:artisanhub11/pages/auth/login.dart';
import 'package:artisanhub11/pages/auth/register.dart';
import 'package:artisanhub11/pages/auth_check_wrapper.dart';
import 'package:artisanhub11/pages/events_screen.dart';
import 'package:artisanhub11/pages/home.dart';
import 'package:artisanhub11/pages/product_screen.dart';
import 'package:artisanhub11/routes/Routenames.dart';
import 'package:artisanhub11/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';



// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
 
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   print("Handling a background message: ${message.messageId}");
//   print("Notification Title (Background): ${message.notification?.title}");
//   print("Notification Body (Background): ${message.notification?.body}");
//   print("Data (Background): ${message.data}");
 
// }

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Firebase sebelum runApp
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  // Daftarkan handler background messaging
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthCheckWrapper(),
      routes: {
        Routenames.home: (context) => const Homepage(),
        Routenames.login: (context) => const LoginScreen(),
        Routenames.register: (context) => const RegisterScreen(),
        Routenames.events: (context) => const EventsScreen(),
        Routenames.wrapper: (context) => const AuthCheckWrapper(),
        Routenames.aboutUs: (context) => const AboutUsScreen(),
      },
      theme: appTheme,
    );
  }
}