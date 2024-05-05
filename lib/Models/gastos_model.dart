class GastosModel {
  int? idGastos;
  String nombre;
  int valor;
  DateTime fecha;

  GastosModel(
      {this.idGastos,
      required this.nombre,
      required this.valor,
      required this.fecha});

  factory GastosModel.fromJson(Map<String, dynamic> json) {
    return GastosModel(
      idGastos: json['id_gastos'],
      nombre: json['nombre'],
      valor: json['valor'],
      fecha: DateTime.parse(json['fecha']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_gastos': idGastos,
      'nombre': nombre,
      'valor': valor,
      'fecha': fecha.toIso8601String().substring(0, 10),
    };
  }
}
