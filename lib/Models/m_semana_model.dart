class MSemanaModel {
  int? idSemana;
  DateTime fechaInicio;
  DateTime? fechaFin;
  int idGastos;

  MSemanaModel(
      {this.idSemana,
      required this.fechaInicio,
      this.fechaFin,
      required this.idGastos,
      });

  factory MSemanaModel.fromJson(Map<String, dynamic> json) {
    return MSemanaModel(
      idSemana: json['id_semana'],
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin: DateTime.parse(json['fecha_fin']),
      idGastos: json['id_gastos'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_semana': idSemana,
      'fecha_inicio': fechaInicio.toIso8601String().substring(0, 10),
      'fecha_fin': fechaFin?.toIso8601String().substring(0, 10),
      'id_gastos': idGastos,
    };
  }
}
