import 'package:flutter/material.dart';
import 'package:cafetero/DataBase/Dao/ventas_cafe_dao.dart';
import 'package:cafetero/Models/ventas_cafe_model.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class RegistrarVenta extends StatefulWidget {
  final int idCosecha;

  const RegistrarVenta({required this.idCosecha,super.key});

  @override
  _RegistrarVentaState createState() => _RegistrarVentaState();
}

class _RegistrarVentaState extends State<RegistrarVenta> {

  bool guardando = false;

  Map<String, dynamic>? result;
  List<VentasCafeModel> ventas = [];
  int ventaTotal = 0;
  int valorKilo = 0;
  int kilosVendidos = 0;
  DateTime selectedDate = DateTime.now();

  final TextEditingController valorPorKiloController = TextEditingController();
  final TextEditingController pagoTotalController = TextEditingController();
  final TextEditingController kilosVendidosController = TextEditingController();

  @override
  void initState() {
    super.initState();
    mostrarVentasGuardadas();
    //for (var venta in ventas) {
    //print(venta);
    //}
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  
  void limpiarCampos() {
    valorPorKiloController.clear();
    pagoTotalController.clear();
    kilosVendidosController.clear();
    selectedDate = DateTime.now();
    setState(() {
      ventaTotal = 0;
      valorKilo = 0;
      kilosVendidos = 0;
      ventas = [];
    });
  }


  Future<void> mostrarVentasGuardadas() async {
    List<VentasCafeModel> ventasBD = await VentasCafeDao().readAll();
    setState(() {
      ventas = ventasBD;
    });
    for (var venta in ventas) {
          print('Fecha: ${venta.fecha}, Kilos Vendidos: ${venta.kilosVendidos}, IDCOSECHA: ${venta.idCosecha}');
        }
  }

  void guardarJornal() async {
    if ( ventaTotal > 0 && valorKilo > 0 && kilosVendidos > 0) 
    {
      final int? id = widget.idCosecha;
      if (id != null && id !=0) {
        final VentasCafeModel venta = VentasCafeModel(
          valorKilo: valorKilo,
          ventaTotal: ventaTotal,
          kilosVendidos: kilosVendidos,
          idCosecha: id,
          fecha: selectedDate,
        );
        await VentasCafeDao().insert(venta);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Registro exitoso',
                style: TextStyle(color: Theme.of(context).colorScheme.surface),
              ),
            ),
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            backgroundColor: Theme.of(context).colorScheme.onError,
          ),
        );
        limpiarCampos();
        mostrarVentasGuardadas();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener la información necesaria')),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Center(
          child: Text(
            'Por favor, llena todos los campos',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Theme.of(context).colorScheme.onError,
      ));
    }
  }


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "VENTA DE CAFE",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Center( 
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 3),
                  const Text('Valor por Kilo:'),
                  Container(
                    width: 230,
                    padding: const EdgeInsets.only(top: 4),
                    child: TextField(
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      controller: valorPorKiloController,
                      onChanged: (value) {
                        setState(() {
                          valorKilo = int.tryParse(value) ?? 0;
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Ingresa el valor',
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 3),
                  const Text('Venta Total:'),
                  Container(
                    width: 230,
                    padding: const EdgeInsets.only(top: 4),
                    child: TextField(
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      controller: pagoTotalController,
                      onChanged: (value) {
                        setState(() {
                          ventaTotal = int.tryParse(value) ?? 0;
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Ingresa el pago total',
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 3),
                  const Text('Kilos Vendidos:'),
                  Container(
                    width: 230,
                    padding: const EdgeInsets.only(top: 4),
                    child: TextField(
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      controller: kilosVendidosController,
                      onChanged: (value) {
                        setState(() {
                          kilosVendidos = int.tryParse(value) ?? 0;
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Ingresa los kilos',
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fecha:'),
                  Container(
                    width: 230,
                    height: 65,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: Colors.black, 
                                colorScheme: const ColorScheme.light(
                                  primary: Color.fromARGB(
                                      255, 131, 155, 42), 
                                  onPrimary: Colors
                                      .white, 
                                  surface: Color(
                                      0xFFC9D1B3), 
                                  onSurface: Colors
                                      .black, 
                                ),
                                buttonTheme: const ButtonThemeData(
                                  textTheme: ButtonTextTheme
                                      .primary, 
                                ),
                              ),
                              child: child!,
                            );
                          },
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(selectedDate),
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(),
                    onPressed: guardarJornal,
                    child: const Text('Guardar'),
                  ),
            ],
          ),
        ))
    );
  }
}