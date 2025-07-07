import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/appbar.dart';
import '../widgets/bottom_nav.dart';

class VehicleListScreen extends StatelessWidget {
  const VehicleListScreen({super.key});

  // Fungsi untuk menampilkan form pop-up penambahan kendaraan
  void _showTambahKendaraanPopup(BuildContext context) {
    // Inisialisasi controller lokal untuk field teks
    final TextEditingController modelController = TextEditingController();
    final TextEditingController nomorPolisiController = TextEditingController();
    final TextEditingController kilometerController = TextEditingController();

    // Variabel untuk dropdown di dalam StatefulBuilder;
    String selectedTransmisi = "Manual";
    String selectedTipeBensin = "Bensin";

    showDialog(
      context: context,
      barrierDismissible: false, // Pengguna tidak bisa menutup dialog dengan tap di luar
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Get keyboard height
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;

            return Stack(
              children: [
                // Efek blur pada background
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(color: Colors.black.withOpacity(0.2)),
                ),
                Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: screenWidth * 0.9,
                      // Adjust max height based on keyboard visibility
                      constraints: BoxConstraints(
                        maxHeight: screenHeight * 0.8 - keyboardHeight,
                      ),
                      // Add margin from bottom when keyboard is visible
                      margin: EdgeInsets.only(
                        bottom: keyboardHeight > 0 ? keyboardHeight + 20 : 0,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SingleChildScrollView(
                        // Add physics to make scrolling smoother
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Tambah Kendaraan",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Divider(color: Colors.grey[300], thickness: 1),
                            // Field Model
                            _buildTextField(modelController, "Model", "Pilih Model Kendaraan"),
                            // Dropdown untuk Transmisi
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: DropdownButtonFormField<String>(
                                value: selectedTransmisi,
                                icon: const Icon(Icons.arrow_drop_down),
                                dropdownColor: Colors.white,
                                decoration: InputDecoration(
                                  labelText: "Transmisi",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: const ["Manual", "Matic"].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedTransmisi = newValue!;
                                  });
                                },
                              ),
                            ),
                            // Dropdown untuk Tipe Bensin
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: DropdownButtonFormField<String>(
                                value: selectedTipeBensin,
                                icon: const Icon(Icons.arrow_drop_down),
                                dropdownColor: Colors.white,
                                decoration: InputDecoration(
                                  labelText: "Tipe Bensin",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: const ["Bensin", "Diesel"].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedTipeBensin = newValue!;
                                  });
                                },
                              ),
                            ),
                            // Field Nomor Polisi
                            _buildTextField(nomorPolisiController, "Nomor Polisi", "R28902KK"),
                            // Field Kilometer dengan input numerik
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Kilometer Saat Ini", style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  TextField(
                                    controller: kilometerController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "30000",
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  child: const Text("Close"),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    // Ambil nilai dari tiap controller dan dropdown
                                    final model = modelController.text.trim();
                                    final nomorPolisi = nomorPolisiController.text.trim();
                                    final kilometer = kilometerController.text.trim();

                                    // Validasi sederhana
                                    if (model.isEmpty || nomorPolisi.isEmpty || kilometer.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Mohon lengkapi semua data kendaraan")),
                                      );
                                      return;
                                    }

                                    // Dapatkan user yang sedang login
                                    User? currentUser = FirebaseAuth.instance.currentUser;
                                    if (currentUser == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("User belum login")),
                                      );
                                      return;
                                    }

                                    try {
                                      // Simpan data kendaraan ke Firestore
                                      // Create a document reference first
                                      final docRef = FirebaseFirestore.instance.collection("vehicles").doc();
                                      final id = docRef.id;

                                      await docRef.set({
                                        "id": id,
                                        "userId": currentUser.uid,
                                        "model": model,
                                        "transmisi": selectedTransmisi,
                                        "tipe_bensin": selectedTipeBensin,
                                        "nomor_polisi": nomorPolisi,
                                        "kilometer": kilometer,
                                        "createdAt": FieldValue.serverTimestamp(),
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Kendaraan berhasil ditambahkan")),
                                      );
                                      Navigator.pop(context);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Gagal menyimpan data kendaraan: $e")),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text("Simpan", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Fungsi pembantu untuk membangun TextField biasa
  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil user yang sedang login
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: const CustomAppBar(title: "Kendaraan Saya"),
        body: const Center(child: Text("User belum login")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "KENDARAAN SAYA"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection("vehicles")
              .where("userId", isEqualTo: currentUser.uid)
              .orderBy("createdAt", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            // Tampilkan indikator loading selama koneksi
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // Tampilkan error jika ada
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            // Jika tidak ada data kendaraan
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Belum ada kendaraan terdaftar."));
            }

            final vehicleDocs = snapshot.data!.docs;
            return ListView.builder(
              itemCount: vehicleDocs.length,
              itemBuilder: (context, index) {
                final vehicleDoc = vehicleDocs[index];
                final vehicle = vehicleDoc.data();
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
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
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // Tampilkan dialog konfirmasi hapus
                        final bool confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Hapus Kendaraan"),
                            content: const Text("Apakah anda yakin ingin menghapus kendaraan ini?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text("Batal"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm) {
                          try {
                            await FirebaseFirestore.instance
                                .collection("vehicles")
                                .doc(vehicleDoc.id)
                                .delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Kendaraan berhasil dihapus")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Gagal menghapus kendaraan: $e")),
                            );
                          }
                        }
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTambahKendaraanPopup(context),
        backgroundColor: Colors.red,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}