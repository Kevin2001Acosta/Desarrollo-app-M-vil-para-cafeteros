import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              title: Text('Texto de ejemplo 1'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Texto de ejemplo 2'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Texto de ejemplo 3'),
            ),
          ),
        ],
      ),
    );
  }

  void initFunction() {
    // Aquí puedes agregar la lógica que deseas ejecutar en el init
  }
}
