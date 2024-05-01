class RecogidaModel {
  int? idRecogida;
  int jornal;
  DateTime fechaInicio;
  DateTime? fechaFin;
  int? kilosTotales;
  int precioKilo;
  int idCosecha;

  RecogidaModel({
    this.idRecogida,
    required this.jornal,
    required this.fechaInicio,
    this.fechaFin,
    this.kilosTotales,
    required this.precioKilo,
    required this.idCosecha,
  });

  Map<String, dynamic> toJson() {
    return {
      'jornal':? jornal,
      'fecha_inicio': fechaInicio.toIso8601String().substring(0, 10),
      'fecha_fin': fechaFin.toIso8601String().substring(0, 10),
      'kilos_totales': kilosTotales,
      'precio_kilo': precioKilo,
      'id_cosecha': idCosecha,
    };
  }

  Map<String, dynamic> toEndJson() {
    return {
      'id_recogida': idRecogida,
      'fecha_fin': fechaFin?.toIso8601String().substring(0, 10),
      'kilos_totales': kilosTotales
    };
  }

  factory RecogidaModel.fromJson(Map<String, dynamic> json) {
    return RecogidaModel(
      idRecogida: json['id_recogida'],
      jornal: json['jornal'],
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin:
          json['fecha_fin'] != null ? DateTime.parse(json['fecha_fin']) : null,
      kilosTotales: json['kilos_totales'],
      precioKilo: json['precio_kilo'],
      idCosecha: json['id_cosecha'],
    );
  }
}
