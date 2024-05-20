// dialogo_recogida.dart
import 'package:flutter/material.dart';
import 'package:cafetero/Screens/trabajo_recogida_page.dart';
import 'package:flutter/services.dart';

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
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: precioKiloController,
                  decoration: InputDecoration(
                    //labelText: 'Precio por kilo',
                    label: const Text('Precio por kilo',
                        style: TextStyle(color: Color(0xFF356724))),
                    //labelStyle: const TextStyle(color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF356724)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF356724)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF356724)),
                      borderRadius: BorderRadius.circular(10),
                    ),
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
            child: Text('Cancelar',
                style: TextStyle(color: Theme.of(context).colorScheme.surface)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
              'Iniciar',
              style: TextStyle(color: Theme.of(context).colorScheme.surface),
            ),
            onPressed: () {
              var precio = int.tryParse(precioKiloController.text);
              if (precio != null && precio > 0) {
                Navigator.of(context).pop({
                  'precioKilo': precioKiloController.text,
                });
              } else {
                Navigator.of(context).pop(); // Cierra el AlertDialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.white,
                    content: Text('Por favor, ingresa un precio válido.',
                        style: TextStyle(color: Colors.red)),
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
