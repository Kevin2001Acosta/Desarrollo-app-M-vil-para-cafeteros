import 'package:cafetero/DataBase/Dao/m_semana_dao.dart';
import 'package:flutter/material.dart';

const itemSize = 120.0;

class PagosJornalesPage extends StatefulWidget {
  final int semanaActual;
  const PagosJornalesPage({required this.semanaActual, super.key});

  @override
  State<PagosJornalesPage> createState() => _PagosJornalesPageState();
}

class _PagosJornalesPageState extends State<PagosJornalesPage> {
  final scrollController = ScrollController();
  List<Map<String, dynamic>> pagosTrabajadores = [];

  void onListen() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getpagosTrabajadores(); // Obtén los datos de SQLite
    scrollController.addListener(onListen);
  }

  void getpagosTrabajadores() async {
    final pagos = await MSemanaDao().pagosSemana(widget.semanaActual);
    setState(() {
      pagosTrabajadores = pagos;
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(onListen);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'PAGOS DE JORNALES',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            left: 15.0, right: 15.0, top: 40.0, bottom: 40.0),
        child: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            const SliverPadding(padding: EdgeInsets.only(top: 50.0)),
            // ...
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  const heightFactor = 0.5;
                  final item =
                      pagosTrabajadores[index]; // Usa los datos de SQLite
                  final itemPositionOffset = index * itemSize * heightFactor;
                  final difference =
                      scrollController.offset - itemPositionOffset;
                  final percent =
                      1.0 - (difference / (itemSize * heightFactor));
                  double opacity = percent;
                  double scale = percent;
                  if (opacity > 1.0) opacity = 1.0;
                  if (opacity < 0.0) opacity = 0.0;
                  if (percent > 1.0) scale = 1.0;

                  return Align(
                    heightFactor: heightFactor,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..scale(scale, scale),
                        child: Card(
                          elevation: 10.0,
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black45, width: 2.0),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0)),
                          ),
                          color: const Color(0xFFC9D1B3),
                          //shadowColor: Colors.black,
                          child: SizedBox(
                            height: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Text('${item['nombre']}: ',
                                            style: const TextStyle(
                                                //color: Colors.white,
                                                fontSize: 20)),
                                      ),
                                      Text(item['pago_total'].toString(),
                                          style: const TextStyle(
                                              //color: Colors.white,
                                              fontSize: 20)),
                                    ],
                                  ),
                                ),
                                Text(item['descripciones'],
                                    style: const TextStyle(
                                        //color: Colors.white,
                                        fontSize: 20))
                              ],
                            ),
                          ),
                          // Aquí es donde usarías los datos de tu mapa para construir tu Card
                          // Por ejemplo, podrías usar item['nombre'] para obtener el nombre
                        ),
                      ),
                    ),
                  );
                },
                childCount: pagosTrabajadores
                    .length, // Usa la longitud de tus datos de SQLite
              ),
            ),
          ],
        ),
      ),
    );
  }
}
