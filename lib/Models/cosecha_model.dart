class CosechaModel {
  int? idCosecha;
  DateTime fechaInicio;
  DateTime? fechaFin;
  int? kilosTotales;

  CosechaModel(
      {this.idCosecha,
      required this.fechaInicio,
      this.fechaFin,
      this.kilosTotales});

  factory CosechaModel.fromJson(Map<String, dynamic> json) {
    return CosechaModel(
      idCosecha: json['id_cosecha'],
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin:
          json['fecha_fin'] != null ? DateTime.parse(json['fecha_fin']) : null,
      kilosTotales: json['kilos_totales'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_cosecha'] = idCosecha;
    data['fecha_inicio'] = fechaInicio.toIso8601String().substring(0, 10);
    data['fecha_fin'] = fechaFin?.toIso8601String().substring(0, 10);
    data['kilos_totales'] = kilosTotales;
    return data;
  }
}
