import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:artisanhub11/routes/Routenames.dart';
import 'package:artisanhub11/routes/app_router.dart';
import 'package:artisanhub11/theme/theme.dart';
import 'package:artisanhub11/theme/theme_manager.dart';
import 'package:artisanhub11/services/notifService.dart';
import 'package:artisanhub11/services/auth_manager.dart';

// Global object for FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Handler for background messages - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized even if the app is terminated
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');

  if (message.notification != null) {
    _showLocalNotification(message.notification!.title, message.notification!.body);
  }
}

// Function to show local notification
void _showLocalNotification(String? title, String? body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'high_importance_channel', // Must match default_notification_channel_id in AndroidManifest
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    title,
    body,
    platformChannelSpecifics,
    payload: 'notification_payload', // Optional payload for handling taps
  );
}

// Fungsi untuk menjadwalkan notifikasi berulang setiap 5 menit
Future<void> _scheduleRepeatingNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'repeating_channel_id', // ID Channel yang berbeda untuk notifikasi berulang
    'Repeating Notifications',
    channelDescription: 'This channel is used for repeating notifications every 5 minutes.',
    importance: Importance.low, // Bisa diatur lebih rendah jika tidak terlalu penting
    priority: Priority.low,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.periodicallyShow(
    1, // ID unik untuk notifikasi berulang ini
    'Waktu ArtisanHub!', // Judul notifikasi
    'Sudah 5 menit! Yuk cek karya baru atau event menarik!', // Isi notifikasi
    RepeatInterval.everyMinute, // Menggunakan everyMinute karena every5Minutes tidak ada langsung
    platformChannelSpecifics,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
  print('Repeating notification scheduled for every minute.');
}

// Fungsi untuk membatalkan notifikasi berulang (jika diperlukan)
Future<void> _cancelRepeatingNotification() async {
  await flutterLocalNotificationsPlugin.cancel(1); // Gunakan ID yang sama
  print('Repeating notification cancelled.');
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Memastikan Flutter engine diinisialisasi

  // Memuat variabel lingkungan dari file .env
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(); // Menginisialisasi Firebase

  // Mendaftarkan handler pesan latar belakang Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Menginisialisasi plugin flutter_local_notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // Ikon aplikasi Anda
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      // Menangani notifikasi iOS di latar depan saat aplikasi berjalan
      print('Local Notification Received (iOS foreground): ID=$id, Title=$title');
      showSimpleNotification(
        Text(title ?? ''),
        subtitle: Text(body ?? ''),
        background: Colors.blueAccent, // Menggunakan warna tema sebagai contoh
        duration: const Duration(seconds: 3),
      );
    },
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // Menangani ketukan notifikasi saat aplikasi di latar depan, latar belakang, atau dihentikan.
      print('Notification tapped with payload: ${response.payload}');
      // Contoh: Navigator.pushNamed(context, '/detailScreen', arguments: response.payload);
    },
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeManager(), // Menyediakan ThemeManager ke widget tree
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
    _scheduleRepeatingNotification(); // Menjadwalkan notifikasi berulang saat aplikasi pertama kali dijalankan
  }

  Future<void> _setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Meminta izin notifikasi (untuk iOS dan Android 13+)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for notifications');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Mendapatkan token perangkat
    String? fcmToken = await messaging.getToken();
    print("FCM Token: $fcmToken");

    // Mengirim token ke backend menggunakan NotificationService
    if (fcmToken != null) {
      String? authToken = await AuthManager.getAuthToken();
      if (authToken != null) {
        NotificationService notificationService = NotificationService();
        final result = await notificationService.registerDeviceToken(
            fcmToken,
            Theme.of(context).platform == TargetPlatform.iOS ? 'ios' : 'android');
        if (result['success']) {
          print('FCM token registered successfully on backend.');
        } else {
          print('Failed to register FCM token on backend: ${result['message']}');
        }
      } else {
        print('User not logged in, skipping FCM token registration to backend.');
      }
    }

    // Menangani pesan di latar depan (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message.notification!.title, message.notification!.body);

        // Menampilkan pop-up notifikasi di dalam aplikasi menggunakan overlay_support
        showSimpleNotification(
          GestureDetector( // GestureDetector untuk membuat pop-up bisa diklik
            onTap: () {
              print("Overlay notification tapped!");
              OverlaySupportEntry.of(context)?.dismiss(); // Menutup pop-up saat diklik
            },
            child: Column( // Menggunakan Column untuk menyusun judul dan subjudul
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.notification!.title ?? 'New Notification'),
                if (message.notification!.body != null)
                  Text(message.notification!.body!),
              ],
            ),
          ),
          background: Theme.of(context).primaryColor, // Menggunakan warna tema utama
          duration: const Duration(seconds: 4),
        );
      }
    });

    // Menangani pesan saat aplikasi dibuka dari keadaan terminated (dihentikan)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state with message: ${message.messageId}');
        // Logika untuk navigasi atau pemrosesan data berdasarkan pesan
      }
    });

    // Menangani pesan saat aplikasi dibuka dari keadaan background (pengguna mengetuk notifikasi)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background with message: ${message.messageId}');
      // Logika untuk navigasi atau pemrosesan data berdasarkan pesan
      // Contoh: Navigator.pushNamed(context, Routenames.someDetailScreen, arguments: message.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return OverlaySupport.global( // Wrapper untuk menampilkan notifikasi pop-up di seluruh aplikasi
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ArtisanHub',
        theme: appTheme, // Menggunakan tema terang yang didefinisikan // Menggunakan tema gelap yang didefinisikan
        themeMode: themeManager.themeMode, // Mengontrol mode tema (terang/gelap)
        initialRoute: Routenames.wrapper, // Rute awal untuk pengecekan otentikasi
        onGenerateRoute: AppRouter.onGenerateRoute, // Penanganan rute dinamis
      ),
    );
  }
}