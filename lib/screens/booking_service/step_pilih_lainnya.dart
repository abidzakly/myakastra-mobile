import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_akastra_app/enums.dart';
import 'package:my_akastra_app/models/service.dart';
import 'package:my_akastra_app/models/vehicle.dart';
import 'package:my_akastra_app/screens/booking_service/entity/booking_data.dart';
import 'package:my_akastra_app/screens/booking_service/keranjang_booking_screen.dart';
import 'package:my_akastra_app/utils/constants.dart';
import '../../widgets/appbar.dart';

class PilihLainnyaScreen extends StatefulWidget {
  const PilihLainnyaScreen({
    super.key,
    required this.selectedVehicle,
    required this.selectedServices,
    required this.selectedDate,
    required this.selectedTime,
    required this.onServicesChange,
  });

  final Vehicle? selectedVehicle;
  final List<Service>? selectedServices;
  final DateTime? selectedDate;
  final ScheduleTime? selectedTime;
  final Function(List<Service>?) onServicesChange;

  @override
  _PilihLainnyaScreenState createState() => _PilihLainnyaScreenState();
}

class _PilihLainnyaScreenState extends State<PilihLainnyaScreen> {
  // Text controller for the complaint field
  final TextEditingController _keluhanController = TextEditingController();

  // Future variables for data loading
  Future<DocumentSnapshot<Map<String, dynamic>>>? userDataFuture;

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
  }

  void _refreshData() {
    setState(() {
      _loadData();
    });
  }

  @override
  void dispose() {
    _keluhanController.dispose();
    super.dispose();
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
            _buildKeluhanSection(),
            _buildBottomButtons(
              onServicesChange: widget.onServicesChange,
            ),
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
        final String email =
            data?['email'] ?? currentUser!.email ?? "Email belum diisi";

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
                      style: TextStyle(color: Colors.grey, fontSize: 16),
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
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
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

  Widget _buildKeluhanSection() {
    return Expanded(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Keluhan (Opsional)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _keluhanController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: "Ceritakan Keluhanmu Disini",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons({
    required Function(List<Service>?) onServicesChange,
  }) {
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
                onPressed: () {
                  var bookingData = BookingData.empty();
                  bookingData = bookingData.copyWith(
                    vehicle: widget.selectedVehicle,
                    selectedServices: widget.selectedServices,
                    selectedDate: widget.selectedDate,
                    selectedTime: widget.selectedTime,
                    keluhan: _keluhanController.text,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KeranjangBookingScreen(
                        bookingData: bookingData,
                        onServicesChange: onServicesChange,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                ),
                child: const Text(
                  "Lanjut",
                  style: TextStyle(
                    color: Colors.white,
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
