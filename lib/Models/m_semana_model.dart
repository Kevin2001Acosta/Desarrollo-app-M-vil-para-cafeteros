class MSemanaModel {
  int? idSemana;
  DateTime fechaInicio;
  DateTime? fechaFin;
  

  MSemanaModel(
      {this.idSemana,
      required this.fechaInicio,
      this.fechaFin    
      });

  factory MSemanaModel.fromJson(Map<String, dynamic> json) {
    return MSemanaModel(
      idSemana: json['id_semana'],
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin: json['fecha_fin'] != null ? DateTime.parse(json['fecha_fin']) : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_semana': idSemana,
      'fecha_inicio': fechaInicio.toIso8601String().substring(0, 10),
      'fecha_fin': fechaFin?.toIso8601String().substring(0, 10)
    };
  }
}
