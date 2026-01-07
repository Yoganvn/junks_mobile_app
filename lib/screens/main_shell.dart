import 'package:flutter/material.dart';

// --- IMPORT HALAMAN-HALAMAN ---
// Pastikan path ini sesuai dengan struktur folder di screenshot Anda
import 'home/home_view.dart';
import 'sell/sell_view.dart';
import 'chat/chat_list_view.dart';

// IMPORT PROFILE & WISHLIST (Keduanya ada di folder profile)
import 'profile/profile_view.dart';
import 'profile/wishlist_view.dart'; // <--- INI PENTING

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    // Index 0: Home
    const HomeView(),

    // Index 1: Saved / Wishlist
    // KITA GANTI TEXT BIASA DENGAN HALAMAN ASLINYA
    const WishlistView(),

    // Index 2: Jual
    const SellView(),

    // Index 3: Chat
    const ChatListView(),

    // Index 4: Profile
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan berubah sesuai halaman yang dipilih di _pages
      body: _pages[_selectedIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF222222),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: "Saved",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, size: 28),
              label: "Jual",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: "Chat",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
