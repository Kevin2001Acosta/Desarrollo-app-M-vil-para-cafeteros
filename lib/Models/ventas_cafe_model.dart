class VentasCafeModel {
  int? idVentas;
  int valorKilo;
  int ventaTotal;
  int kilosVendidos;
  int idCosecha;
  DateTime fecha;


  VentasCafeModel(
      {this.idVentas,
      required this.valorKilo,
      required this.ventaTotal,
      required this.kilosVendidos,
      required this.fecha,
      required this.idCosecha,});

  factory VentasCafeModel.fromJson(Map<String, dynamic> json) {
    return VentasCafeModel(
      idVentas: json['id_ventas'],
      valorKilo: json['valor_kilo'],
      ventaTotal: json['venta_total'],
      kilosVendidos: json['kilos_vendidos'],
      idCosecha: json['id_cosecha'],
      fecha: DateTime.parse(json['fecha']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ventas': idVentas,
      'valor_kilo': valorKilo,
      'venta_total': ventaTotal,
      'kilos_vendidos': kilosVendidos,
      'id_cosecha': idCosecha,
      'fecha': fecha.toIso8601String().substring(0, 10),
    };
  }
}
