import 'package:flutter/material.dart';

class PersistentBottomNavBar extends StatelessWidget {
  const PersistentBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  @override
  Widget build(BuildContextcontext) {
    return BottomNavigationBar(
      unselectedLabelStyle: const TextStyle(
        color: Colors.black,
      ),
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.feedback_outlined),
          label: 'Notification',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Stock',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.call_split_rounded),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.delivery_dining_rounded),
          label: 'Deliveries',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: onItemTapped,
    );
  }
}