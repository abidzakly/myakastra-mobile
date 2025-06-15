import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'addVehicle_screen.dart';
import 'vehicleList_screen.dart';
import '../widgets/appbar.dart';

class AccVehicleScreen extends StatelessWidget {
  const AccVehicleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pastikan user sudah login
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
          appBar: const CustomAppBar(title: "Kendaraan Saya"),
          body: const Center(child: Text("User belum login")));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("vehicles")
          .where("userId", isEqualTo: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Kondisi menunggu koneksi
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            appBar: CustomAppBar(title: "Kendaraan Saya"),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Jika snapshot ada tapi dokumen masih kosong, tampilkan AddVehicleScreen
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // Tampilan ketika user belum memiliki data kendaraan
          return const TambahKendaraanScreen();
        } else {
          // Jika sudah ada data kendaraan, tampilkan VehicleListScreen
          return VehicleListScreen();
        }
      },
    );
  }
}