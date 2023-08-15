import 'package:flutter/material.dart';
import 'package:flutter_repositories_poc/routes/settings_page.dart';

class CustomDrawer extends StatelessWidget {
  final Function(String) onNavigation;

  const CustomDrawer({Key? key, required this.onNavigation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              onNavigation('/home');
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              onNavigation('/settings');
            },
          ),
        ],
      ),
    );
  }
}
