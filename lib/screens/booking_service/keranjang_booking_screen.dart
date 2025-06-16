import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_akastra_app/models/service.dart';
import 'package:my_akastra_app/screens/booking_service/confirm_booking_screen.dart';
import 'package:my_akastra_app/screens/booking_service/entity/booking_data.dart';

import '../../widgets/appbar.dart';

class KeranjangBookingScreen extends StatefulWidget {
  const KeranjangBookingScreen({
    super.key,
    required this.bookingData,
    required this.onServicesChange,
  });

  final BookingData bookingData;
  final Function(List<Service>?) onServicesChange;

  @override
  _KeranjangBookingScreenState createState() => _KeranjangBookingScreenState();
}

class _KeranjangBookingScreenState extends State<KeranjangBookingScreen> {
  late BookingData localBookingData; // Changed to late and proper type

  // Currency formatter
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    decimalDigits: 0,
    name: 'Rp ',
    symbol: 'Rp ',
  );

  @override
  void initState() {
    super.initState();
    // Initialize localBookingData with a copy of the original
    localBookingData = widget.bookingData;
  }

  void _refreshData() {
    setState(() {
      // _loadData();
    });
  }

  int get totalPrice {
    if (localBookingData.selectedServices == null ||
        localBookingData.selectedServices!.isEmpty) {
      return 0;
    }
    return localBookingData.selectedServices!
        .fold(0, (sum, service) => sum + (service.price ?? 0));
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
            // Wait a bit for the future to complete
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.grey[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Keranjang Booking',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Layanan yang anda pesan',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Services List - Updated to use localBookingData
              Expanded(
                child: localBookingData.selectedServices == null ||
                    localBookingData.selectedServices!.isEmpty
                    ? const Center(
                  child: Text(
                    'Tidak ada layanan yang dipilih',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: localBookingData.selectedServices!.length,
                  itemBuilder: (context, index) {
                    final service =
                    localBookingData.selectedServices![index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Colors.red.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // Trash icon
                          GestureDetector(
                            onTap: () {
                              _removeService(index);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Service details
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.label ?? 'Unknown Service',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Price
                          Text(
                            currencyFormatter.format(service.price ?? 0),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom section with total and confirmation button - Updated to use localBookingData
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Total row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          currencyFormatter.format(totalPrice),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Disclaimer text
                    Text(
                      '* Biaya belum termasuk part & bahan. Estimasi diberikan setelah konfirmasi booking.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirmation button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: localBookingData.selectedServices == null ||
                            localBookingData.selectedServices!.isEmpty
                            ? null
                            : _confirmBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
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
          )),
    );
  }

  // Fixed _removeService method
  void _removeService(int index) {
    if (localBookingData.selectedServices != null &&
        localBookingData.selectedServices!.isNotEmpty &&
        index >= 0 &&
        index < localBookingData.selectedServices!.length) {
      setState(() {
        // Create a new list without the removed service
        List<Service> updatedServices =
        List.from(localBookingData.selectedServices!);
        updatedServices.removeAt(index);

        // Update localBookingData with the new services list
        localBookingData = localBookingData.copyWith(
          selectedServices: updatedServices,
        );
        widget.onServicesChange(updatedServices);
      });

      // Show confirmation snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Layanan berhasil dihapus'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmBooking() {
    // Check if booking data is complete - Updated to use localBookingData
    if (!localBookingData.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi data booking terlebih dahulu'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmBookingScreen(
          bookingData: localBookingData,
        ),
      ),
    );
  }
}
