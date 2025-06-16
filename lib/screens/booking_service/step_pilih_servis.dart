import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_akastra_app/models/vehicle.dart';
import 'package:my_akastra_app/screens/booking_service/step_pilih_jadwal.dart';
import 'package:my_akastra_app/utils/constants.dart';
import '../../widgets/appbar.dart';
import '../../models/service.dart';
import '../../enums.dart';

class PilihServisScreen extends StatefulWidget {
  const PilihServisScreen({
    super.key,
    required this.selectedVehicle,
  });

  final Vehicle? selectedVehicle;

  @override
  _PilihServisScreenState createState() => _PilihServisScreenState();
}

class _PilihServisScreenState extends State<PilihServisScreen> {
  // Set untuk menyimpan ID service yang dipilih
  Set<String> selectedServiceIds = <String>{};

  // List untuk menyimpan data service yang dipilih
  List<Service> selectedServices = <Service>[];

  // Future variables for data loading
  Future<DocumentSnapshot<Map<String, dynamic>>>? userDataFuture;
  Future<QuerySnapshot<Map<String, dynamic>>>? servicesFuture;

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

    // Load services data
    servicesFuture = FirebaseFirestore.instance
        .collection(FirestoreCollection.kServices)
        .get();
  }

  void _refreshData() {
    setState(() {
      _loadData();
    });
  }

  // Helper method to sync selectedServiceIds with selectedServices
  void _syncSelectedServiceIds() {
    selectedServiceIds = selectedServices.map((service) => service.id!).toSet();
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
            _buildServiceList(),
            _buildBottomButtons(widget.selectedVehicle, selectedServices,
                onServicesChange: (updatedServices) {
                  setState(() {
                    selectedServices = updatedServices ?? selectedServices;
                    // Sync the selectedServiceIds with the updated selectedServices
                    _syncSelectedServiceIds();
                  });
                }),
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
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
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

  Widget _buildServiceList() {
    return Expanded(
      child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: servicesFuture,
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
                    "Error loading services",
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
                  const Icon(Icons.build_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Belum ada layanan tersedia",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Silakan coba lagi nanti",
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

          // Convert documents to Service objects
          final services = snapshot.data!.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add document ID to data
            return Service.fromJson(data);
          }).toList();

          // Group services by service type
          final groupedServices = <ServiceType, List<Service>>{};
          for (final service in services) {
            if (service.serviceType != null) {
              groupedServices
                  .putIfAbsent(service.serviceType!, () => [])
                  .add(service);
            }
          }

          // Define the desired order
          final desiredOrder = [
            ServiceType.servisBerkala,
            ServiceType.bodyCat,
            ServiceType.gantiOli,
            ServiceType.servisUmum,
          ];

          // Create ordered list of entries
          final orderedEntries = <MapEntry<ServiceType, List<Service>>>[];
          for (final serviceType in desiredOrder) {
            if (groupedServices.containsKey(serviceType)) {
              orderedEntries
                  .add(MapEntry(serviceType, groupedServices[serviceType]!));
            }
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: orderedEntries.map((entry) {
              return _buildServiceTypeExpansionTile(entry.key, entry.value);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildServiceTypeExpansionTile(
      ServiceType serviceType, List<Service> services) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade300, width: 1),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          serviceType.label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        iconColor: Colors.red,
        collapsedIconColor: Colors.red,
        childrenPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: services.map((service) {
          final isSelected = selectedServiceIds.contains(service.id);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(
                service.label ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (isSelected) {
                        selectedServiceIds.remove(service.id);
                        selectedServices.removeWhere((s) => s.id == service.id);
                      } else {
                        selectedServiceIds.add(service.id!);
                        selectedServices.add(service);
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    isSelected ? "Ditambahkan" : "Pesan Layanan",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomButtons(
      Vehicle? selectedVehicle,
      List<Service> selectedServices, {
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
                onPressed: selectedServiceIds.isNotEmpty
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PilihJadwalScreen(
                        selectedVehicle: selectedVehicle,
                        selectedServices: selectedServices,
                        onServicesChange: onServicesChange,
                      ),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedServiceIds.isNotEmpty
                      ? Colors.red
                      : Colors.grey[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: selectedServiceIds.isNotEmpty ? 2 : 0,
                ),
                child: Text(
                  "Lanjut",
                  style: TextStyle(
                    color: selectedServiceIds.isNotEmpty
                        ? Colors.white
                        : Colors.grey[600],
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