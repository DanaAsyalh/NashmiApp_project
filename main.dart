

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'screens/welcome_screen.dart';

final ValueNotifier<bool> isArabicNotifier = ValueNotifier<bool>(true); 

class PharmacyInfo {
  final String name;
  final LatLng location;

  PharmacyInfo(this.name, this.location);
}


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("🚨 إشعار وصل بالخلفية: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const NashmiRescueApp());

  
  messaging.subscribeToTopic('all_paramedics').then((value) {
    print(' تم الاشتراك بنجاح في مجموعة المسعفين! التطبيق جاهز لاستقبال نداء 911');
  }).catchError((error) {
    print(' فشل الاشتراك: $error'); 
  });
}

class NashmiRescueApp extends StatelessWidget {
  const NashmiRescueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isArabicNotifier,
      builder: (context, isArabic, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nashmi Rescue',

          theme: ThemeData(
            primarySwatch: Colors.red, 
            fontFamily: isArabic ? 'Tahoma' : 'Roboto',
          ),

          home: const WelcomeScreen(), 

          builder: (context, child) {
            return Directionality(
              textDirection:
                  isArabic ? TextDirection.rtl : TextDirection.ltr,
              
              child: child!,
            );
          },
        );
      },
    );
  }
}
