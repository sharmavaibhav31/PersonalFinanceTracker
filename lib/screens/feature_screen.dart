import 'package:flutter/material.dart';

class FeatureMenu extends StatelessWidget {
  const FeatureMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(child: Text('Menu')),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Transactions'),
          onTap: () {},
        ),
        // add more menu items here
      ],
    );
  }
}

class FeatureScreen extends StatelessWidget {
  const FeatureScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Features')),
      drawer: const Drawer(child: FeatureMenu()),
      body: const Center(child: Text('Select an option from the menu')),
    );
  }
}
