class JornalModel {
  int? idJornal;
  int pagoTrabajador;
  String? descripcion
  DateTime? fecha;
  int idTrabajador;
  int idSemana;

  JornalModel(
      {this.idJornal,
      required this.pagoTrabajador,
      this.descripcion,
      this.fecha,
      required this.idTrabajador,
      required this.idSemana,});

  factory JornalModel.fromJson(Map<String, dynamic> json) {
    return JornalModel(
      idJornal: json['id'],
      pagoTrabajador: json['pago_trabajador'],
      descripcion: json['descripcion'],
      fecha: DateTime.parse(json['fecha']),
      idTrabajador: json['id_trabajador'],
      idSemana: json['id_semana'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id_jornal':? idJornal,
      'pago_trabajador': pagoTrabajador,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String().substring(0, 10),
      'id_trabajador': idTrabajador,
      'id_semana': idSemana,
    };
  }
}
