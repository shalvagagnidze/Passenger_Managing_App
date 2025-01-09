import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Drawer header with app logo or titleS
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_bus,
                      size: 50,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'მგზავრთა მართვა',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Navigation items
            ListTile(
              leading: const Icon(
                Icons.home,
                size: 28,
                color: Colors.blue,
              ),
              title: const Text(
                'მთავარი გვერდი',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            
            const Divider(height: 1),
            
            ListTile(
              leading: const Icon(
                Icons.person,
                size: 28,
                color: Colors.blue,
              ),
              title: const Text(
                'მძღოლები',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/drivers');
              },
            ),
            
            const Divider(height: 1),
            
            // Spacer to push the version info to the bottom
            const Spacer(),
            
            // Version info at the bottom
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'ვერსია 1.0.0',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}