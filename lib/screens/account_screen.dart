import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_akastra_app/screens/accVehicle_screen.dart';
import 'package:my_akastra_app/screens/myProfile_screen.dart';
import 'package:my_akastra_app/screens/privacyPolicy_screen.dart';
import 'package:my_akastra_app/screens/vehicleList_screen.dart';
import '../widgets/appbar.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'addVehicle_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "AKUN SAYA"),
      body: ListView(
        children: [
          _buildProfileOption(
            icon: Icons.person_outline,
            label: "Profil Saya",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyProfileScreen()),
            ),
          ),
          _buildProfileOption(
            icon: Icons.directions_car,
            label: "Daftar Kendaraan",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccVehicleScreen()),
            ),
          ),
          _buildProfileOption(
            icon: Icons.build_circle_outlined,
            label: "Servis Saya",
            onTap: () {},
          ),
          _buildProfileOption(
            icon: Icons.privacy_tip_outlined,
            label: "Kebijakan Privasi",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
            ),
          ),
          _buildProfileOption(
            icon: Icons.lock_outline,
            label: "Ubah Kata Sandi",
            onTap: () {},
          ),
          _buildProfileOption(
            icon: Icons.info_outline,
            label: "Tentang Aplikasi",
            onTap: () {},
          ),
          _buildProfileOption(
            icon: Icons.exit_to_app,
            label: "Keluar",
            onTap: () => _showLogoutDialog(context),
            iconColor: Colors.red,
            textColor: Colors.red,
          ),
          _buildProfileOption(
            icon: Icons.person_off_outlined,
            label: "Hapus Akun",
            onTap: () => _showDeleteAccountDialog(context),
            iconColor: Colors.red,
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.red,
    Color textColor = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 16),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildCustomDialog(
          context,
          title: "Keluar Akun",
          content: "Apakah Anda yakin ingin keluar dari akun?",
          confirmLabel: "Keluar",
          confirmColor: Colors.red,
          onConfirm: () {
            Navigator.pop(context);
            _logoutUser(context);
          },
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildCustomDialog(
          context,
          title: "Hapus Akun",
          content: "Setelah dihapus, akun Anda tidak dapat dipulihkan. Yakin ingin melanjutkan?",
          confirmLabel: "Hapus Akun",
          confirmColor: Colors.red,
          onConfirm: () {
            Navigator.pop(context);
            _deleteUserAccount(context);
          },
        );
      },
    );
  }

  Dialog _buildCustomDialog(
      BuildContext context, {
        required String title,
        required String content,
        required String confirmLabel,
        required Color confirmColor,
        required VoidCallback onConfirm,
      }) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isDeleting
                ? const CircularProgressIndicator()
                : const Icon(Icons.error, color: Colors.orange, size: 50)
                .animate(onPlay: (controller) => controller.repeat())
                .fade(duration: 500.ms)
                .then(delay: 200.ms)
                .fadeOut(duration: 500.ms),
            const SizedBox(height: 8),
            Text(
              _isDeleting ? "Menghapus Akun..." : title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (!_isDeleting)
              Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            const SizedBox(height: 20),
            if (!_isDeleting)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        confirmLabel,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _logoutUser(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: ${e.toString()}')),
      );
    }
  }

  void _deleteUserAccount(BuildContext context) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete(); // Menghapus akun user dari Firebase

        if (mounted) {
          Navigator.pop(context); // Tutup dialog setelah sukses hapus
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Akun berhasil dihapus.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        if (e.toString().contains('requires-recent-login')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesi Anda telah berakhir. Silakan login ulang sebelum menghapus akun.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus akun: ${e.toString()}')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
}
