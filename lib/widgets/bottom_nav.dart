import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius:5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,size: 28,),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book,size: 28),
            label: 'Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history,size: 28),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,size: 28),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}