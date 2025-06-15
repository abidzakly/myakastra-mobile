import 'package:flutter/material.dart';
import 'package:my_akastra_app/screens/booking_service/step_pilih_kendaraan.dart';
import 'package:my_akastra_app/screens/facilities_screen.dart';
import 'package:my_akastra_app/screens/layanan_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/appbar.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static Future<void> _launchWhatsApp(BuildContext context) async {
    final phone = '6283188867000';
    final message = Uri.encodeComponent("Halo, saya ingin bertanya seputar layanan.");
    final whatsappUrl = Uri.parse("https://wa.me/$phone?text=$message");

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      _showError(context, 'Tidak dapat membuka WhatsApp');
    }
  }

  void _testLaunchURL(BuildContext context) async {
    final Uri url = Uri.parse('https://linktr.ee/AkastraToyota');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      debugPrint("Google berhasil dibuka!");
    } else {
      _showError(context, 'Tidak dapat membuka Google');
    }
  }


  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(showLogo: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildServiceButton(
                  context,
                  icon: Icons.phone,
                  label: 'Hubungi CS',
                  onPressed: () => _launchWhatsApp(context),
                ),
                _buildServiceButton(
                  context,
                  icon: Icons.build_circle_outlined,
                  label: 'Booking Servis',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PilihKendaraanScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildServiceButton(
                  context,
                  icon: Icons.settings,
                  label: 'Genuine Parts',
                  onPressed: () => _testLaunchURL(context),
                ),
                _buildServiceButton(
                  context,
                  icon: Icons.info_outline,
                  label: 'Informasi Layanan',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LayananScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildServiceButton(
                  context,
                  icon: Icons.location_city,
                  label: 'Informasi Fasilitas',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FacilitiesScreen()),
                    );
                  },
                ),
                _buildServiceButton(
                  context,
                  icon: Icons.newspaper,
                  label: 'Berita & Tips',
                  onPressed: () {
                    // Navigasi ke halaman berita & tips
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildServiceButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onPressed,
      }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      height: 100,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
