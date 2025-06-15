import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/appbar.dart';
// import '../widgets/bottom_nav.dart'; // Opsional, jika kamu memiliki widget bottom navigation

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil user saat ini
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: "Akun Saya"),
        body: const Center(child: Text("User tidak terdeteksi")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "PROFIL SAYA"),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            // Jika dokumen belum ada, kamu bisa menampilkan pesan atau data default
            return Center(child: Text("Belum ada data, silakan lengkapi profil Anda"));
          }

          // Ambil data dari Firestore
          final data = snapshot.data!.data();
          final name    = data?['name']   ?? 'Nama belum diisi';
          final email   = data?['email']  ?? user.email ?? '';
          final gender  = data?['gender'] ?? 'Jenis Kelamin belum diisi';
          final phone   = data?['phone']  ?? 'No Handphone belum diisi';

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          email,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildProfileItem(context, "Nama", name, user.uid),
                    _buildProfileItem(context, "Jenis Kelamin", gender, user.uid),
                    _buildProfileItem(context, "No Handphone", phone, user.uid),
                    _buildProfileItem(context, "Email", email, user.uid),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileItem(
      BuildContext context, String title, String value, String uid) {
    return Column(
      children: [
        ListTile(
          title: Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(value, style: const TextStyle(color: Colors.grey)),
          trailing: const Icon(Icons.arrow_forward_ios,
              size: 16, color: Colors.grey),
          onTap: () => _showBottomSheet(context, title, value, uid),
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }

  // Bottom Sheet untuk mengedit dan menyimpan informasi ke Firestore
  void _showBottomSheet(
      BuildContext context, String title, String value, String uid) {
    TextEditingController controller = TextEditingController(text: value);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit, color: Colors.red),
                  hintText: "Masukkan $title",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String newValue = controller.text;
                  String field;

                  // Mapping judul ke field Firestore
                  if (title.toLowerCase().contains("nama")) {
                    field = "name";
                  } else if (title.toLowerCase().contains("jenis kelamin")) {
                    field = "gender";
                  } else if (title.toLowerCase().contains("no handphone")) {
                    field = "phone";
                  } else if (title.toLowerCase().contains("email")) {
                    field = "email";
                  } else {
                    field = title.toLowerCase();
                  }

                  try {
                    // Simpan data ke Firestore
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(uid)
                        .set({field: newValue}, SetOptions(merge: true));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Data berhasil disimpan!")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gagal menyimpan data: $e")),
                    );
                  }

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text("Simpan",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}
