import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/appbar.dart';

class PilihServisScreen extends StatefulWidget {
  const PilihServisScreen({Key? key}) : super(key: key);

  @override
  _PilihServisScreenState createState() => _PilihServisScreenState();
}

class _PilihServisScreenState extends State<PilihServisScreen> {
  // Variabel untuk menyimpan ID dan data kendaraan yang dipilih.
  String? selectedVehicleId;
  Map<String, dynamic>? selectedVehicleData;

  @override
  Widget build(BuildContext context) {
    // Ambil user saat ini.
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: "BOOKING SERVICE"),
        body: const Center(child: Text("User tidak terdeteksi")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "BOOKING SERVICE"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfo(user),
          _buildTabNavigation(),
          const SizedBox(height: 16),
          _buildVehicleList(user),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildUserInfo(User user) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection("users").doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Data akun belum tersedia"),
          );
        }
        final data = snapshot.data!.data();
        final String name = data?['name'] ?? "Nama belum diisi";
        final String email =
            data?['email'] ?? user.email ?? "Email belum diisi";

        return Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Row(
            children: [
              // CircleAvatar diperbesar (radius 40 dan icon size 50)
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 28, color: Colors.red),
              ),
              const SizedBox(width: 15),
              // Informasi akun dengan font yang lebih besar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabNavigation() {
    return const Column(
      children: [
        // Divider selebar card (padding horizontal 16)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(thickness: 1.0, color: Colors.grey),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 1, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Pilih Kendaraan",
                style:
                TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "Servis",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              Text(
                "Jadwal",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              Text(
                "Lainnya",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleList(User user) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("vehicles")
            .where("userId", isEqualTo: user.uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada kendaraan, silakan tambah kendaraan Anda."));
          }
          final vehicleDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: vehicleDocs.length,
            itemBuilder: (context, index) {
              final vehicleDoc = vehicleDocs[index];
              final vehicle = vehicleDoc.data();
              final vehicleId = vehicleDoc.id;
              final isSelected = selectedVehicleId == vehicleId;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedVehicleId = null;
                          selectedVehicleData = null;
                        } else {
                          selectedVehicleId = vehicleId;
                          selectedVehicleData = vehicle;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      key: ValueKey(vehicleId),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? Colors.red : Colors.grey.shade300,
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ]
                            : [],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          vehicle["model"] ?? "",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text("Transmisi: ${vehicle["transmisi"] ?? ""}"),
                            Text("Tipe Bensin: ${vehicle["tipe_bensin"] ?? vehicle["bensin"] ?? ""}"),
                            Text("Nomor Polisi: ${vehicle["nomor_polisi"] ?? ""}"),
                            Text("Kilometer: ${vehicle["kilometer"] ?? ""}"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Kembali", style: TextStyle(color: Colors.red)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: selectedVehicleId != null
                  ? () {
                Navigator.pushNamed(
                  context,
                  '/nextServiceStep',
                  arguments: selectedVehicleData,
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedVehicleId != null ? Colors.red : Colors.grey[300],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Lanjut", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
