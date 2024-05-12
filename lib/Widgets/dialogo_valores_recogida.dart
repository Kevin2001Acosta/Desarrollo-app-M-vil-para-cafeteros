// dialogo_recogida.dart
import 'package:flutter/material.dart';
import 'package:cafetero/Screens/trabajo_recogida_page.dart';

Future<Map<String, dynamic>?> mostrarDialogoRecogida(
    BuildContext context, Recogida tipo) {
  //final precioDiaController = TextEditingController();
  final precioKiloController = TextEditingController();
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Iniciar Recogida'),
        content: SizedBox(
          height: 150.0,
          child: Column(
            children: <Widget>[
              if (tipo == Recogida.kiliado)
                TextField(
                  controller: precioKiloController,
                  decoration: const InputDecoration(
                    labelText: 'Precio por kilo',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    // Guarda el valor en alguna parte
                  },
                ),
              if (tipo != Recogida.alDia && tipo != Recogida.kiliado)
                // Aquí puedes agregar un widget por defecto
                const Text('Por favor, selecciona un tipo de recogida'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Iniciar'),
            onPressed: () {
              // Aquí puedes recoger las respuestas y los precios y devolverlos
              Navigator.of(context).pop({
                'precioKilo': precioKiloController.text,
              });
            },
          ),
        ],
      );
    },
  );
}
