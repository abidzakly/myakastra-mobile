import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'package:my_akastra_app/enums.dart';
import 'package:my_akastra_app/models/order.dart' as orderModel;
import 'package:my_akastra_app/models/service.dart';
import 'package:my_akastra_app/models/vehicle.dart';
import 'package:my_akastra_app/screens/booking_service/step_pilih_lainnya.dart';
import 'package:my_akastra_app/utils/colors.dart';
import 'package:my_akastra_app/utils/constants.dart';
import '../../widgets/appbar.dart';

class PilihJadwalScreen extends StatefulWidget {
  const PilihJadwalScreen({
    super.key,
    required this.selectedVehicle,
    required this.selectedServices,
    required this.onServicesChange,
  });

  final Vehicle? selectedVehicle;
  final List<Service>? selectedServices;
  final Function(List<Service>?) onServicesChange;

  @override
  _PilihJadwalScreenState createState() => _PilihJadwalScreenState();
}

class _PilihJadwalScreenState extends State<PilihJadwalScreen> {
  DateTime? selectedDate;
  ScheduleTime? selectedTime;
  Map<ScheduleTime, int> timeSlotCounts = {};
  bool isLoadingTimeSlots = false;

  // Future variables for data loading
  Future<DocumentSnapshot<Map<String, dynamic>>>? userDataFuture;

  // User instance
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    // Set default date to today
    selectedDate = DateTime.now();
    _loadTimeSlotAvailability();

    if (currentUser != null) {
      _loadUserData();
    }
  }

  void _loadUserData() {
    if (currentUser == null) return;

    // Load user data
    userDataFuture = FirebaseFirestore.instance
        .collection(FirestoreCollection.kUsers)
        .doc(currentUser!.uid)
        .get();
  }

  void _refreshData() {
    setState(() {
      _loadUserData();
      _loadTimeSlotAvailability();
    });
  }

  Future<void> _loadTimeSlotAvailability() async {
    if (selectedDate == null) return;

    setState(() {
      isLoadingTimeSlots = true;
    });

    try {
      // Create start and end of selected date
      final startOfDay =
          DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
      final endOfDay = DateTime(selectedDate!.year, selectedDate!.month,
          selectedDate!.day, 23, 59, 59);

      // Query orders for the selected date
      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('scheduled_date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduled_date',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      // Count orders for each time slot
      Map<ScheduleTime, int> counts = {};
      for (ScheduleTime timeSlot in ScheduleTime.values) {
        counts[timeSlot] = 0;
      }

      for (var doc in querySnapshot.docs) {
        try {
          final order = orderModel.Order.fromJson(doc.data());
          if (order.scheduledTime != null) {
            counts[order.scheduledTime!] =
                (counts[order.scheduledTime!] ?? 0) + 1;
          }
        } catch (e) {
          // Handle parsing errors gracefully
          print('Error parsing order: $e');
        }
      }

      setState(() {
        timeSlotCounts = counts;
        isLoadingTimeSlots = false;
      });
    } catch (e) {
      print('Error loading time slot availability: $e');
      setState(() {
        isLoadingTimeSlots = false;
      });
    }
  }

  Color _getTimeSlotColor(int count) {
    if (count >= 4) return Colors.red;
    if (count == 3) return Colors.orange;
    if (count == 2) return Colors.yellow;
    return Colors.green;
  }

  bool _isTimeSlotSelectable(int count) {
    return count < 4;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedTime = null; // Reset selected time when date changes
      });
      await _loadTimeSlotAvailability();
    }
  }

  void _showConfirmationDialog(ScheduleTime timeToConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: Colors.orange.shade600,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),

                // Confirmation text
                const Text(
                  'Apakah anda yakin untuk memilih di jam ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Tidak',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Close confirmation dialog
                          Navigator.pop(context);
                          // Update the actual selectedTime
                          setState(() {
                            selectedTime = timeToConfirm;
                          });
                          // Close time selection dialog
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Ya',
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
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTimeDialog() {
    // Use a temporary variable to track selection in dialog
    ScheduleTime? tempSelectedTime = selectedTime;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Stack(
              children: [
                // Backdrop filter
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
                // Dialog content
                Dialog(
                  backgroundColor: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        const Text(
                          'Pilih Waktu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Time slots grid
                        if (isLoadingTimeSlots)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(color: Colors.red),
                          )
                        else
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: ScheduleTime.values.map((timeSlot) {
                              final count = timeSlotCounts[timeSlot] ?? 0;
                              final color = _getTimeSlotColor(count);
                              final isSelectable = _isTimeSlotSelectable(count);
                              final isSelected = tempSelectedTime == timeSlot;

                              return GestureDetector(
                                onTap: isSelectable
                                    ? () {
                                        setDialogState(() {
                                          tempSelectedTime = timeSlot;
                                        });
                                      }
                                    : null,
                                child: Container(
                                  width: 80,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected ? color : Colors.white,
                                    border: Border.all(
                                      color: color,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      timeSlot.label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 20),

                        // Legend
                        Column(
                          children: [
                            _buildLegendItem(Colors.red, 'Penuh'),
                            _buildLegendItem(Colors.orange, 'Ramai'),
                            _buildLegendItem(Colors.yellow, 'Sedikit Ramai'),
                            _buildLegendItem(
                                Colors.green, 'Sedikit Pengunjung'),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.red, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  'Kembali',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: tempSelectedTime != null
                                    ? () {
                                        // Show confirmation dialog
                                        _showConfirmationDialog(
                                            tempSelectedTime!);
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: tempSelectedTime != null
                                      ? Colors.red
                                      : Colors.grey[300],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  elevation: tempSelectedTime != null ? 2 : 0,
                                ),
                                child: Text(
                                  'Lanjut',
                                  style: TextStyle(
                                    color: tempSelectedTime != null
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
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

  Widget _buildBottomButtons({
    Vehicle? selectedVehicle,
    List<Service>? selectedServices,
    DateTime? selectedDate,
    ScheduleTime? selectedTime,
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
                onPressed: (selectedDate != null && selectedTime != null)
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PilihLainnyaScreen(
                              selectedVehicle: selectedVehicle,
                              selectedServices: selectedServices,
                              selectedDate: selectedDate,
                              selectedTime: selectedTime,
                              onServicesChange: onServicesChange,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      (selectedDate != null && selectedTime != null)
                          ? Colors.red
                          : Colors.grey[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation:
                      (selectedDate != null && selectedTime != null) ? 2 : 0,
                ),
                child: Text(
                  "Lanjut",
                  style: TextStyle(
                    color: (selectedDate != null && selectedTime != null)
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

            // Date and Time selection content
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tanggal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    selectedDate != null
                                        ? _formatDate(selectedDate!)
                                        : 'Pilih tanggal',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: selectedDate != null
                                          ? Colors.black87
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Time selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Waktu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: selectedDate != null ? _showTimeDialog : null,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: selectedDate != null
                                  ? Colors.white
                                  : Colors.grey.shade50,
                              border: Border.all(
                                color: selectedDate != null
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade200,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: selectedDate != null
                                      ? Colors.red
                                      : Colors.grey.shade400,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    selectedTime != null
                                        ? selectedTime!.label
                                        : (selectedDate != null
                                            ? 'Pilih waktu'
                                            : 'Pilih tanggal terlebih dahulu'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: selectedTime != null
                                          ? Colors.black87
                                          : (selectedDate != null
                                              ? Colors.grey.shade600
                                              : Colors.grey.shade400),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_right,
                                  color: selectedDate != null
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Add some bottom padding for better scrolling
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            _buildBottomButtons(
              selectedVehicle: widget.selectedVehicle,
              selectedServices: widget.selectedServices,
              selectedDate: selectedDate,
              selectedTime: selectedTime,
              onServicesChange: widget.onServicesChange,
            ),
          ],
        ),
      ),
    );
  }
}
