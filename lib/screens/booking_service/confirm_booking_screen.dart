import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_akastra_app/screens/booking_service/entity/booking_data.dart';
import 'package:intl/intl.dart';
import 'package:my_akastra_app/utils/constants.dart';

import '../../widgets/appbar.dart';

class ConfirmBookingScreen extends StatefulWidget {
  const ConfirmBookingScreen({
    super.key,
    required this.bookingData,
  });

  final BookingData bookingData;

  @override
  _ConfirmBookingScreenState createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  // Future variables for data loading
  Future<DocumentSnapshot<Map<String, dynamic>>>? userDataFuture;
  User? currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  void _refreshData() {
    setState(() {
      // _loadData();
    });
  }

  // Calculate total price
  int get totalPrice {
    if (widget.bookingData.selectedServices == null) return 0;
    return widget.bookingData.selectedServices!
        .fold(0, (sum, service) => sum + (service.price ?? 0));
  }

  // Format currency
  String formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Format date for display
  String formatDisplayDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  // Show confirmation dialog
  void _showConfirmationDialog() {
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
                  'Apakah Anda yakin ingin melanjutkan?',
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
                        onPressed: _isLoading
                            ? null
                            : () {
                          Navigator.pop(context);
                          _submitBooking();
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

  // Submit booking to Firestore
  Future<void> _submitBooking() async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final scheduledDateTime = DateTime(
        widget.bookingData.selectedDate!.year,
        widget.bookingData.selectedDate!.month,
        widget.bookingData.selectedDate!.day,
        int.parse(widget.bookingData.selectedTime!.label.split(':')[0]),
        int.parse(widget.bookingData.selectedTime!.label.split(':')[1]),
      );
      final collection = FirebaseFirestore.instance.collection(FirestoreCollection.kOrders);
      final id = collection.doc().id;
      final orderData = {
        'id': id,
        'created_at': Timestamp.fromDate(now),
        'issue': widget.bookingData.keluhan ?? '',
        'order_status': 'IN_PROGRESS',
        'ordered_service_ids': widget.bookingData.selectedServices!
            .map((service) => service.id!)
            .toList(),
        'scheduled_date': Timestamp.fromDate(scheduledDateTime),
        'scheduled_time': widget.bookingData.selectedTime!.label,
        'updated_at': Timestamp.fromDate(now),
        'userId': currentUser!.uid,
        'vehicle_id': widget.bookingData.vehicle!.id!,
        'total_bill': totalPrice,
      };

      await collection.doc(id).set(orderData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "BOOKING SERVICE"),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: Colors.red,
        onRefresh: () async {
          _refreshData();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vehicle Type Section
                    _buildSectionCard(
                      title: 'Tipe Kendaraan',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.directions_car,
                                color: Colors.red,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              widget.bookingData.vehicle?.model ??
                                  "Unknown Model",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                _buildInfoRowForVehicle(
                                    Icons.settings,
                                    "Transmisi",
                                    widget.bookingData.vehicle?.transmisi),
                                _buildInfoRowForVehicle(
                                    Icons.local_gas_station,
                                    "Tipe Bensin",
                                    widget.bookingData.vehicle?.tipeBensin),
                                _buildInfoRowForVehicle(
                                    Icons.confirmation_number,
                                    "Nomor Polisi",
                                    widget.bookingData.vehicle?.nomorPolisi),
                                _buildInfoRowForVehicle(
                                    Icons.speed,
                                    "Kilometer",
                                    widget.bookingData.vehicle?.kilometer
                                        ?.toString()),
                              ],
                            ),
                            trailing: const Icon(Icons.check_circle,
                                color: Colors.red, size: 24),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Service Schedule Section
                    _buildSectionCard(
                      title: 'Jadwal Servis',
                      child: Text(
                        '${formatDisplayDate(widget.bookingData.selectedDate)} ${widget.bookingData.selectedTime?.label}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Complaint Section
                    _buildSectionCard(
                      title: 'Keluhan',
                      child: Container(
                        width: double.infinity,
                        // minHeight: 100,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.bookingData.keluhan?.isEmpty ?? true
                              ? '-'
                              : widget.bookingData.keluhan!,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.bookingData.keluhan?.isEmpty ?? true
                                ? Colors.grey[500]
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Booking Service Section
                    _buildSectionCard(
                      title: 'Booking Servis',
                      child: Column(
                        children: [
                          // Service items
                          if (widget.bookingData.selectedServices != null)
                            ...widget.bookingData.selectedServices!.map(
                                  (service) => _buildServiceItem(
                                service.label ?? '-',
                                service.price ?? 0,
                              ),
                            ),

                          const Divider(height: 32),

                          // Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'TOTAL',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formatCurrency(totalPrice),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '* Biaya belum termasuk part & bahan. Estimasi diberikan setelah konfirmasi booking.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100), // Space for bottom buttons
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                      _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Batal',
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
                      onPressed: _isLoading ? null : _showConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Konfirmasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.red, width: 1.5),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.05),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildInfoRowForVehicle(IconData icon, String label, String? value) {
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

  Widget _buildServiceItem(String serviceName, int price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(right: 12),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              serviceName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            formatCurrency(price),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}