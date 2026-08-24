

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'screens/welcome_screen.dart';

final ValueNotifier<bool> isArabicNotifier = ValueNotifier<bool>(true); 
// افتراضياً عربي... منطقي يعني 

class PharmacyInfo {
  final String name;
  final LatLng location;

  PharmacyInfo(this.name, this.location);
  //ممكن اشتغل عليه بعدين
}


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("🚨 إشعار وصل بالخلفية: ${message.notification?.title}");
  // لو ما اشتغلت... غالباً المشكلة من Firebase (أكيد مش مني طبعاً )
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  // بدون هاي السطر الأشياء بتخرب بطريقة غريبة… بعرفش كيف

  // تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ربط الإشعارات بالخلفية
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // طلب صلاحيات الإشعارات (يارب المستخدم يوافق )
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // تشغيل واجهة التطبيق أول عشان الشاشة تفتح فوراً وما تعلق! 
  runApp(const NashmiRescueApp());

  // الاشتراك التلقائي في مجموعة "كل المسعفين" 
  // (بدون await عشان يشتغل بصمت بالخلفية والتطبيق فاتح)
  messaging.subscribeToTopic('all_paramedics').then((value) {
    print('✅ تم الاشتراك بنجاح في مجموعة المسعفين! التطبيق جاهز لاستقبال نداء 911');
  }).catchError((error) {
    print('❌ فشل الاشتراك: $error'); //أكيد المشكلة من فايربيس مش مني 
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
          debugShowCheckedModeBanner: false, // لأنه شكله مزعج بصراحة
          title: 'Nashmi Rescue',

          theme: ThemeData(
            primarySwatch: Colors.red, // أحمر = طوارئ = منطقي
            fontFamily: isArabic ? 'Tahoma' : 'Roboto',
            // لو الخط خرب... blame fonts مش الكود 
          ),

          home: const WelcomeScreen(), 
          // نقطة البداية… كل الطرق تؤدي لهون

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