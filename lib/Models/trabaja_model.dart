class TrabajaModel {
  int? idTrabaja;
  int idTrabajador;
  int idRecogida;
  int pago;
  int kilosTrabajador;
  DateTime fecha;
  String? nombre;

  TrabajaModel({
    this.idTrabaja,
    required this.idTrabajador,
    required this.idRecogida,
    required this.pago,
    required this.kilosTrabajador,
    required this.fecha,
    this.nombre,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_trabaja': idTrabaja,
      'id_trabajador': idTrabajador,
      'id_recogida': idRecogida,
      'pago': pago,
      'kilos_trabajador': kilosTrabajador,
      'fecha': fecha.toIso8601String().substring(0, 10)
    };
  }

  factory TrabajaModel.fromJson(Map<String, dynamic> json) {
    return TrabajaModel(
      idTrabaja: json['id_trabaja'],
      idTrabajador: json['id_trabajador'],
      idRecogida: json['id_recogida'],
      pago: json['pago'],
      kilosTrabajador: json['kilos_trabajador'],
      fecha: DateTime.parse(json['fecha']),
      nombre: json['nombre'],
    );
  }
}
