import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_akastra_app/models/vehicle.dart';
import 'package:my_akastra_app/screens/booking_service/step_pilih_servis.dart';
import 'package:my_akastra_app/utils/constants.dart';
import '../../widgets/appbar.dart';

class PilihKendaraanScreen extends StatefulWidget {
  const PilihKendaraanScreen({Key? key}) : super(key: key);

  @override
  _PilihKendaraanScreenState createState() => _PilihKendaraanScreenState();
}

class _PilihKendaraanScreenState extends State<PilihKendaraanScreen> {
  // Selection state variables
  String? selectedVehicleId;
  Map<String, dynamic>? selectedVehicleData;

  // Future variables for data loading
  Future<DocumentSnapshot<Map<String, dynamic>>>? userDataFuture;
  Future<QuerySnapshot<Map<String, dynamic>>>? vehiclesFuture;

  // User instance
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _loadData();
    }
  }

  void _loadData() {
    if (currentUser == null) return;

    // Load user data
    userDataFuture = FirebaseFirestore.instance
        .collection(FirestoreCollection.kUsers)
        .doc(currentUser!.uid)
        .get();

    // Load vehicles data
    vehiclesFuture = FirebaseFirestore.instance
        .collection(FirestoreCollection.kVehicles)
        .where(kUserId, isEqualTo: currentUser!.uid)
        .orderBy(kCreatedAt, descending: true)
        .get();
  }

  void _refreshData() {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        appBar: CustomAppBar(title: "BOOKING SERVICE"),
        body: Center(child: Text("User tidak terdeteksi")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "BOOKING SERVICE"),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: Colors.red,
        onRefresh: () async {
          _refreshData();
          // Wait a bit for the future to complete
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo(),
            _buildTabNavigation(),
            const SizedBox(height: 16),
            _buildVehicleList(),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: userDataFuture,
      builder: (context, snapshot) {
        // Show loading only on first load
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Handle error
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("Error loading user data: ${snapshot.error}"),
                ElevatedButton(
                  onPressed: _refreshData,
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        // Handle no data
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Data akun belum tersedia"),
          );
        }

        final data = snapshot.data!.data();
        final String name = data?['name'] ?? "Nama belum diisi";
        final String email = data?['email'] ?? currentUser!.email ?? "Email belum diisi";

        return Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 28, color: Colors.red),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
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
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabNavigation() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(thickness: 1.0, color: Colors.grey),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Pilih Kendaraan",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
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
              // Refresh button
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.grey, size: 20),
                onPressed: _refreshData,
                tooltip: "Refresh data",
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleList() {
    return Expanded(
      child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: vehiclesFuture,
        builder: (context, snapshot) {
          // Show loading only on first load
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading vehicles",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${snapshot.error}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshData,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          // Handle no data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Belum ada kendaraan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Silakan tambah kendaraan Anda terlebih dahulu",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshData,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refresh"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final vehicleDocs = snapshot.data!.docs;

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
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
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ]
                            : [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.red.shade50 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.directions_car,
                            color: isSelected ? Colors.red : Colors.grey.shade600,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          vehicle["model"] ?? "Unknown Model",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.red : Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.settings, "Transmisi", vehicle["transmisi"]),
                            _buildInfoRow(Icons.local_gas_station, "Tipe Bensin", vehicle["tipe_bensin"] ?? vehicle["bensin"]),
                            _buildInfoRow(Icons.confirmation_number, "Nomor Polisi", vehicle["nomor_polisi"]),
                            _buildInfoRow(Icons.speed, "Kilometer", vehicle["kilometer"]),
                          ],
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Colors.red, size: 24)
                            : const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 24),
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

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value ?? "Tidak tersedia",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Kembali",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: selectedVehicleId != null
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PilihServisScreen(
                        selectedVehicle: selectedVehicleData != null
                            ? Vehicle.fromJson(selectedVehicleData!)
                            : null,
                      ),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedVehicleId != null ? Colors.red : Colors.grey[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: selectedVehicleId != null ? 2 : 0,
                ),
                child: Text(
                  "Lanjut",
                  style: TextStyle(
                    color: selectedVehicleId != null ? Colors.white : Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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