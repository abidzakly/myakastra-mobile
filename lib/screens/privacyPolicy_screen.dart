import 'package:flutter/material.dart';

import '../widgets/appbar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "KEBIJAKAN PRIVASI"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(text: "KEBIJAKAN PRIVASI AKASTRA "),
                  TextSpan(
                    text: "TOYOTA",
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            _buildDivider(),

            const SizedBox(height: 10),
            _buildBodyText(
              "Akastra Toyota berkomitmen untuk ",
              "melindungi dan menjaga kerahasiaan data pribadi pelanggan kami.",
              "Sebagai bagian dari komitmen ini, kami menerapkan kebijakan privasi yang dirancang untuk memastikan keamanan dan privasi setiap informasi yang Anda berikan kepada kami.",
            ),
            const SizedBox(height: 10),

            _buildBodyText(
              "Melalui kebijakan ini, kami menjelaskan bagaimana data pelanggan kami ",
              "dikumpulkan, digunakan, dan dilindungi",
              " dalam semua layanan yang tersedia di Bengkel Akastra Toyota.",
            ),

            const SizedBox(height: 10),
            _buildBodyText(
              "Kami menghargai kepercayaan Anda dan berupaya untuk mematuhi standar tertinggi dalam menjaga integritas informasi pribadi Anda.",
              " Untuk informasi lebih lanjut mengenai kebijakan privasi kami, silakan tinjau detail berikut ini.",
              "",
            ),

            const SizedBox(height: 20),

            _buildSectionTitle("A. Perolehan & Pengumpulan Data"),
            const SizedBox(height: 5),
            _buildDivider(),
            const SizedBox(height: 10),
            _buildBulletPoint(
                "Akastra Toyota memperoleh & mengumpulkan data yang dikirimkan oleh pengguna aplikasi digital kami yang sedang diakses saat ini:"),
            _buildBulletPoint(
                "Kami mengumpulkan data dari aktivitas pengguna saat mengunjungi website kami, seperti klik Call To Action Button, like artikel dll."),
            _buildBulletPoint(
                "Selain itu kami juga mendapatkan data dari pengguna yang melakukan login & pendaftaran akun."),
            _buildBulletPoint(
                "Pengguna yang melakukan interaksi dengan beberapa Channel sosial media Akastra Toyota (Facebook, TikTok, Youtube & Instagram)."),
            _buildBulletPoint("Pengguna yang melakukan booking service."),

            const SizedBox(height: 20),

            _buildSectionTitle("B. Penggunaan Data"),
            const SizedBox(height: 5),
            _buildDivider(),
            const SizedBox(height: 10),
            _buildBulletPoint(
                "Akastra Toyota dapat menggunakan keseluruhan atau sebagian data yang diperoleh dan dikumpulkan dari Pengguna."),
            _buildBulletPoint(
                "Menggunakan pesan notifikasi terkait promo & diskon servis baik melalui telepon, surat elektronik dll."),
            _buildBulletPoint(
                "Mengelola serta memproses seluruh transaksi yang telah dilakukan di Akastra Toyota."),
            _buildBulletPoint(
                "Menggunakan historical servis customer yang berguna dalam analisis kebutuhan servis kendaraan."),
          ],
        ),
      ),
    );
  }

  // Widget untuk membangun teks paragraf dengan highlight
  Widget _buildBodyText(String normalText, String boldText, String afterBold) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black, height: 1.5),
        children: [
          TextSpan(text: normalText),
          TextSpan(
            text: boldText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: afterBold),
        ],
      ),
    );
  }

  // Widget untuk membangun judul bagian
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
    );
  }

  // Widget untuk membangun bullet point
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk garis pemisah
  Widget _buildDivider() {
    return Container(
      width: 60,
      height: 4,
      color: Colors.black,
    );
  }
}
