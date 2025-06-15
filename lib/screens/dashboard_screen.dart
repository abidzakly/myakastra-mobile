import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../widgets/carousel_slider.dart';
import '../widgets/service_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(showLogo: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CarouselSlider(),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "SOLUSI SERVIS ",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        TextSpan(
                          text: "MOBIL KAMU",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Nikmati layanan Akastra Motor sekarang. Banyak Cashbacknya!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ServiceCard(
              title: "UJI EMISI",
              description: "Memastikan bahwa kendaraan Anda beroperasi secara bersih dan ramah lingkungan.",
              icon: Icons.emoji_transportation,
            ),
            ServiceCard(
              title: "GENERAL REPAIR",
              description: "Membantu Anda melakukan perawatan kendaraan dengan servis berkala dan servis umum lainnya.",
              icon: Icons.build,
            ),
            ServiceCard(
              title: "BODY PAINT",
              description: "Akastra menyediakan servis cat kendaraan, poles all body, grooming, dan servis body paint lainnya.",
              icon: Icons.format_paint,
            ),
            ServiceCard(
              title: "SPOORING & BALANCING",
              description: "Menjaga keseimbangan roda kendaraan Anda, memberikan pengalaman berkendara yang lebih lancar dan aman.",
              icon: Icons.directions_car,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
