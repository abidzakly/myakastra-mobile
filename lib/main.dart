import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_akastra_app/screens/accVehicle_screen.dart';
import 'package:my_akastra_app/screens/account_screen.dart';
import 'package:my_akastra_app/screens/addVehicle_screen.dart';
import 'package:my_akastra_app/screens/booking_service/step_pilih_kendaraan.dart';
import 'package:my_akastra_app/screens/facilities_screen.dart';
import 'package:my_akastra_app/screens/layanan_screen.dart';
import 'package:my_akastra_app/screens/myProfile_screen.dart';
import 'package:my_akastra_app/screens/register_screen.dart';
import 'package:my_akastra_app/screens/vehicleList_screen.dart';
import 'package:my_akastra_app/screens/splash_screen.dart';
import 'package:my_akastra_app/screens/login_screen.dart';
import 'package:my_akastra_app/screens/main_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id');

  print('Firebase berhasil diinisialisasi');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Akastra Service',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: SplashScreen(), // Mulai dari SplashScreen

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/addVehicle': (context) => const TambahKendaraanScreen(),
        '/listVehicle': (context) => const VehicleListScreen(),
        '/accVehicle': (context) => const AccVehicleScreen(),
        '/account': (context) => const AccountScreen(),
        '/profile': (context) => const MyProfileScreen(),
        '/step_pilihKendaraan': (context) => const PilihKendaraanScreen(),
        '/facilities': (context) => const FacilitiesScreen(),
        '/layanan': (context) => const LayananScreen()
      },

      // Gunakan onGenerateRoute untuk menangani navigasi yang lebih fleksibel
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          return MaterialPageRoute(builder: (context) => const MainScreen());
        }
        return null;
      },
    );
  }
}
