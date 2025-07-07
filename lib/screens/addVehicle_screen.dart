import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/appbar.dart';
import '../widgets/bottom_nav.dart';

class TambahKendaraanScreen extends StatefulWidget {
  const TambahKendaraanScreen({super.key});

  @override
  State<TambahKendaraanScreen> createState() => _TambahKendaraanScreenState();
}

class _TambahKendaraanScreenState extends State<TambahKendaraanScreen> {
  // Controller untuk field input teks
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _nomorPolisiController = TextEditingController();
  final TextEditingController _kilometerController = TextEditingController();

  // State untuk dropdown
  String _selectedTransmisi = "Manual";
  String _selectedTipeBensin = "Bensin";

  @override
  void dispose() {
    // _modelController.dispose();
    // _nomorPolisiController.dispose();
    // _kilometerController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan popup form penambahan kendaraan
  void _showTambahKendaraanPopup(BuildContext context) {
    // Sebelum memunculkan popup, kita bisa set flag modal visible
    // (flag ini bisa digunakan bila ingin menampilkan loading state atau animasi khusus)
    setState(() {});

    showDialog(
      context: context,
      barrierDismissible: false, // agar pengguna tidak bisa menutup dialog dengan tap di luar
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
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
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SingleChildScrollView(
                        // Agar tampilan tidak terpotong saat keyboard muncul
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Tambah Kendaraan",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Divider(color: Colors.grey[300], thickness: 1),
                            // Field Model
                            _buildTextField(_modelController, "Model", "Pilih Model Kendaraan"),
                            const SizedBox(height: 8),
                            // Dropdown Transmisi
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: DropdownButtonFormField<String>(
                                value: _selectedTransmisi,
                                icon: const Icon(Icons.arrow_drop_down),
                                dropdownColor: Colors.white,
                                decoration: InputDecoration(
                                  labelText: "Transmisi",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: const ["Manual", "Matic"].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: const TextStyle(color: Colors.black)),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setStateModal(() {
                                    _selectedTransmisi = newValue!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Dropdown Tipe Bensin
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: DropdownButtonFormField<String>(
                                value: _selectedTipeBensin,
                                icon: const Icon(Icons.arrow_drop_down),
                                dropdownColor: Colors.white,
                                decoration: InputDecoration(
                                  labelText: "Tipe Bensin",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: const ["Bensin", "Diesel"].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: const TextStyle(color: Colors.black)),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setStateModal(() {
                                    _selectedTipeBensin = newValue!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Field Nomor Polisi
                            _buildTextField(_nomorPolisiController, "Nomor Polisi", "R28902KK"),
                            const SizedBox(height: 8),
                            // Field Kilometer dengan input numerik
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Kilometer Saat Ini", style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  TextField(
                                    controller: _kilometerController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "30000",
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      filled: true,
                                      fillColor: Colors.white,
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
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  child: const Text("Close"),
                                ),
                                // Replace the existing save logic in your ElevatedButton onPressed method
                                ElevatedButton(
                                  onPressed: () async {
                                    // Ambil nilai dari controller dan dropdown
                                    final model = _modelController.text.trim();
                                    final nomorPolisi = _nomorPolisiController.text.trim();
                                    final kilometer = _kilometerController.text.trim();

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
                                      // Create a document reference first
                                      final docRef = FirebaseFirestore.instance.collection("vehicles").doc();
                                      final id = docRef.id;

                                      // Simpan data kendaraan pada koleksi "vehicles"
                                      await docRef.set({
                                        "id": id,
                                        "userId": currentUser.uid,
                                        "model": model,
                                        "transmisi": _selectedTransmisi,
                                        "tipe_bensin": _selectedTipeBensin,
                                        "nomor_polisi": nomorPolisi,
                                        "kilometer": kilometer,
                                        "createdAt": FieldValue.serverTimestamp(),
                                      });

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Kendaraan berhasil ditambahkan")),
                                      );
                                      // Tutup dialog popup
                                      Navigator.pop(context);
                                      // Navigasi ke screen yang menampilkan list kendaraan.
                                      Navigator.pushReplacementNamed(context, '/accVehicle');
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
    ).whenComplete(() {
      setState(() {});
    });
  }

  // Widget pembantu untuk menghasilkan TextField standar
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
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan statis untuk layar AddVehicle yang mengarahkan user ke popup form
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "KENDARAAN SAYA"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Tambah Kendaraan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 5),
            const Center(
              child: Text(
                "Menambahkan kendaraan membantu Anda dalam melakukan booking service di Akastra Toyota",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showTambahKendaraanPopup(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Yuk, Tambahkan Data Kendaraan Sekarang!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
