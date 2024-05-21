import 'package:flutter/material.dart';

class PagosJornalesPage extends StatefulWidget {
  const PagosJornalesPage({super.key});

  @override
  State<PagosJornalesPage> createState() => _PagosJornalesPageState();
}

class _PagosJornalesPageState extends State<PagosJornalesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagos de jornales'),
      ),
      body: const Column(
        children: [
          Text('Pagos de jornales'),
        ],
      ),
    );
  }
}
